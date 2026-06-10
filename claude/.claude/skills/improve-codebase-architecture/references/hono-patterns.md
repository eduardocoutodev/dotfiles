# Hono.js Backend — Canonical Patterns & Smells

Opinionated patterns for Hono.js backends. The goal is the same as any backend: domain logic stays pure, infrastructure stays at the edges, routes stay thin.

---

## Ideal Project Structure

```
src/
├── domain/                  ← pure business logic, zero Hono imports
│   ├── entities/            ← types/classes representing core concepts
│   ├── services/            ← domain services (pure functions preferred)
│   ├── events/              ← domain event types
│   └── errors/              ← typed domain errors
├── application/             ← use cases: orchestrate domain + ports
│   └── use-cases/
├── infrastructure/          ← all I/O concerns
│   ├── db/                  ← Drizzle/Prisma/Kysely adapters
│   ├── queue/               ← BullMQ, Kafka adapters
│   ├── email/               ← Resend, Nodemailer adapters
│   └── storage/             ← S3, R2 adapters
├── http/                    ← Hono-specific layer
│   ├── routes/              ← one file per resource/domain
│   ├── middleware/          ← auth, logging, error handling
│   ├── validators/          ← Zod schemas for request/response
│   └── mappers/             ← domain → response DTO
├── lib/                     ← shared utilities (not domain)
│   └── hono.ts              ← app factory, middleware composition
└── index.ts                 ← entry point, wires everything
```

---

## Pattern: App Factory

Never create the Hono app inline in `index.ts`. Use a factory so it's testable.

```typescript
// src/lib/hono.ts
import { Hono } from "hono";
import { logger } from "hono/logger";
import { errorHandler } from "../http/middleware/error-handler";
import { authMiddleware } from "../http/middleware/auth";

export type AppEnv = {
  Variables: {
    userId: string;
    db: Database;
  };
  Bindings: {
    DATABASE_URL: string;
    JWT_SECRET: string;
  };
};

export function createApp(): Hono<AppEnv> {
  const app = new Hono<AppEnv>();

  app.use("*", logger());
  app.use("/api/*", authMiddleware);
  app.onError(errorHandler);

  return app;
}

// src/index.ts
import { createApp } from "./lib/hono";
import { tableRoutes } from "./http/routes/tables";
import { orderRoutes } from "./http/routes/orders";

const app = createApp();

app.route("/api/tables", tableRoutes);
app.route("/api/orders", orderRoutes);

export default app;
```

---

## Pattern: Route Files (Thin Controllers)

Routes should: validate input, call a use case, map to response. Nothing else.

```typescript
// src/http/routes/orders.ts
import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import { PlaceOrderSchema } from "../validators/order.validators";
import { PlaceOrderUseCase } from "../../application/use-cases/place-order";
import { toOrderResponse } from "../mappers/order.mapper";
import type { AppEnv } from "../../lib/hono";

export const orderRoutes = new Hono<AppEnv>();

orderRoutes.post("/", zValidator("json", PlaceOrderSchema), async (c) => {
  const body = c.req.valid("json");
  const userId = c.get("userId");

  const useCase = new PlaceOrderUseCase(c.get("db")); // or DI container
  const order = await useCase.execute({ ...body, userId });

  return c.json(toOrderResponse(order), 201);
});

orderRoutes.get("/:id", async (c) => {
  const id = c.req.param("id");
  const useCase = new GetOrderUseCase(c.get("db"));
  const order = await useCase.execute(id);
  if (!order) return c.notFound();

  return c.json(toOrderResponse(order));
});
```

**Anti-patterns**:

- Business logic inside route handlers
- Direct DB calls inside routes
- `try/catch` in every route (use `app.onError` instead)

---

## Pattern: Zod Validators (Separate Layer)

Keep Zod schemas in their own file. They define the contract of your HTTP API.

```typescript
// src/http/validators/order.validators.ts
import { z } from "zod";

export const PlaceOrderSchema = z.object({
  tableId: z.string().uuid(),
  items: z
    .array(
      z.object({
        productId: z.string().uuid(),
        quantity: z.number().int().positive(),
        notes: z.string().optional(),
      }),
    )
    .min(1),
});

export const UpdateOrderStatusSchema = z.object({
  status: z.enum(["PENDING", "CONFIRMED", "READY", "DELIVERED", "CANCELLED"]),
});

// Types derived from schemas — single source of truth
export type PlaceOrderInput = z.infer<typeof PlaceOrderSchema>;
export type UpdateOrderStatusInput = z.infer<typeof UpdateOrderStatusSchema>;
```

**Anti-pattern**: Validation logic inline in routes, or domain types used directly as request bodies.

---

## Pattern: Centralized Error Handler

One error handler. Domain errors map to HTTP status codes here, not in routes.

```typescript
// src/http/middleware/error-handler.ts
import type { ErrorHandler } from "hono";
import { HTTPException } from "hono/http-exception";
import { ZodError } from "zod";
import {
  DomainError,
  NotFoundError,
  ValidationError,
} from "../../domain/errors";

export const errorHandler: ErrorHandler = (err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status);
  }

  if (err instanceof ZodError) {
    return c.json({ error: "Validation failed", details: err.flatten() }, 422);
  }

  if (err instanceof NotFoundError) {
    return c.json({ error: err.message }, 404);
  }

  if (err instanceof ValidationError) {
    return c.json({ error: err.message }, 400);
  }

  if (err instanceof DomainError) {
    return c.json({ error: err.message }, 422);
  }

  console.error("Unhandled error:", err);
  return c.json({ error: "Internal server error" }, 500);
};
```

---

## Pattern: Typed Domain Errors

```typescript
// src/domain/errors/index.ts
export class DomainError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "DomainError";
  }
}

export class NotFoundError extends DomainError {
  constructor(entity: string, id: string) {
    super(`${entity} with id ${id} not found`);
    this.name = "NotFoundError";
  }
}

export class ValidationError extends DomainError {
  constructor(message: string) {
    super(message);
    this.name = "ValidationError";
  }
}

export class ConflictError extends DomainError {
  constructor(message: string) {
    super(message);
    this.name = "ConflictError";
  }
}
```

---

## Pattern: Use Cases

Same shape as Java — one class per use case, takes a command, returns a result.

```typescript
// src/application/use-cases/place-order.ts
import type { Database } from "../../infrastructure/db/client";
import type { OrderRepository } from "../../domain/ports/order-repository";
import type { TableRepository } from "../../domain/ports/table-repository";
import { Order } from "../../domain/entities/order";
import { NotFoundError, ValidationError } from "../../domain/errors";

export interface PlaceOrderCommand {
  userId: string;
  tableId: string;
  items: Array<{ productId: string; quantity: number; notes?: string }>;
}

export class PlaceOrderUseCase {
  constructor(
    private readonly orderRepo: OrderRepository,
    private readonly tableRepo: TableRepository,
  ) {}

  async execute(command: PlaceOrderCommand): Promise<Order> {
    const table = await this.tableRepo.findById(command.tableId);
    if (!table) throw new NotFoundError("Table", command.tableId);
    if (!table.isAvailable())
      throw new ValidationError("Table is not available for ordering");

    const order = Order.create(command);
    await this.orderRepo.save(order);

    return order;
  }
}
```

---

## Pattern: Repository Port (Interface in Domain, Impl in Infra)

```typescript
// src/domain/ports/order-repository.ts  ← domain defines the contract
export interface OrderRepository {
  findById(id: string): Promise<Order | null>;
  findByTable(tableId: string): Promise<Order[]>;
  save(order: Order): Promise<void>;
  update(order: Order): Promise<void>;
}

// src/infrastructure/db/drizzle-order-repository.ts  ← infra implements it
export class DrizzleOrderRepository implements OrderRepository {
  constructor(private readonly db: DrizzleDB) {}

  async findById(id: string): Promise<Order | null> {
    const row = await this.db.query.orders.findFirst({
      where: eq(orders.id, id),
    });
    return row ? OrderMapper.toDomain(row) : null;
  }

  async save(order: Order): Promise<void> {
    await this.db.insert(orders).values(OrderMapper.toRow(order));
  }
  // ...
}
```

---

## Pattern: Auth Middleware

```typescript
// src/http/middleware/auth.ts
import type { MiddlewareHandler } from "hono";
import { HTTPException } from "hono/http-exception";
import { verifyToken } from "../../lib/jwt";

export const authMiddleware: MiddlewareHandler = async (c, next) => {
  const token = c.req.header("Authorization")?.replace("Bearer ", "");
  if (!token) throw new HTTPException(401, { message: "Missing token" });

  const payload = await verifyToken(token, c.env.JWT_SECRET);
  if (!payload) throw new HTTPException(401, { message: "Invalid token" });

  c.set("userId", payload.sub);
  await next();
};
```

---

## Pattern: Response Mappers

Domain objects → response DTOs. Never expose domain internals directly.

```typescript
// src/http/mappers/order.mapper.ts
import type { Order } from "../../domain/entities/order";

export interface OrderResponse {
  id: string;
  tableId: string;
  status: string;
  items: Array<{ productId: string; quantity: number; totalPrice: number }>;
  total: number;
  createdAt: string;
}

export function toOrderResponse(order: Order): OrderResponse {
  return {
    id: order.id,
    tableId: order.tableId,
    status: order.status,
    items: order.items.map((item) => ({
      productId: item.productId,
      quantity: item.quantity,
      totalPrice: item.totalPrice,
    })),
    total: order.total,
    createdAt: order.createdAt.toISOString(),
  };
}
```

---

## Common Smells in Hono Codebases

### [INFRA LEAKAGE] — DB queries in route handlers

```typescript
// ❌ Route doing DB work directly
app.get("/orders/:id", async (c) => {
  const order = await db.query.orders.findFirst({
    where: eq(orders.id, c.req.param("id")),
  });
  return c.json(order);
});

// ✅ Route delegates to use case
app.get("/orders/:id", async (c) => {
  const order = await new GetOrderUseCase(orderRepo).execute(c.req.param("id"));
  if (!order) return c.notFound();
  return c.json(toOrderResponse(order));
});
```

### [PATTERN INCONSISTENCY] — Mixed error handling

```typescript
// ❌ try/catch in every route
app.post("/orders", async (c) => {
  try {
    // ...
  } catch (e) {
    return c.json({ error: "something went wrong" }, 500);
  }
});

// ✅ throw, let app.onError handle it
app.post("/orders", async (c) => {
  const order = await placeOrderUseCase.execute(body); // throws typed errors
  return c.json(toOrderResponse(order), 201);
});
```

### [SHALLOW MODULE] — One-line use cases

If a use case only calls one repository method, the use case is redundant — merge the logic or enrich the domain instead.

### [HIGH COGNITIVE LOAD] — Middleware doing too much

Split middleware by concern: auth, request ID, logging, rate limiting — each its own file/function.
