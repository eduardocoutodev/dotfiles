# React 19 + TanStack Query + TanStack Router — Canonical Patterns

Modern React frontend architecture. The goal: components describe UI, hooks own async state, routes own data loading, domain logic lives in query/mutation factories — not scattered across components.

---

## Ideal Project Structure

```
src/
├── features/                ← feature-first, not layer-first
│   ├── orders/
│   │   ├── api/             ← query/mutation definitions (TanStack Query factories)
│   │   │   └── orders.queries.ts
│   │   ├── hooks/           ← custom hooks built on top of query factories
│   │   │   ├── use-orders.ts
│   │   │   └── use-place-order.ts
│   │   ├── components/      ← pure UI components for this feature
│   │   │   ├── OrderCard.tsx
│   │   │   └── OrderList.tsx
│   │   └── types.ts         ← feature-local types/schemas (Zod)
│   └── tables/
│       ├── api/
│       ├── hooks/
│       └── components/
├── routes/                  ← TanStack Router route definitions
│   ├── __root.tsx
│   ├── index.tsx
│   ├── orders/
│   │   ├── index.tsx        ← /orders list route
│   │   └── $orderId.tsx     ← /orders/:id detail route
│   └── dashboard.tsx
├── components/              ← shared/global UI (not feature-specific)
│   ├── ui/                  ← primitive components (Button, Input, etc.)
│   └── layout/              ← Shell, Sidebar, Header
├── lib/
│   ├── api-client.ts        ← base fetch/axios instance
│   └── query-client.ts      ← QueryClient singleton config
└── main.tsx
```

**Key rule**: features own everything about themselves. If a hook or component is only used by one feature, it lives inside that feature, not in a global folder.

---

## Pattern: Query Factory (TanStack Query)

Define queries as factories — not inline inside hooks. This makes them composable, reusable in loaders, and type-safe.

```typescript
// src/features/orders/api/orders.queries.ts
import { queryOptions, infiniteQueryOptions } from "@tanstack/react-query";
import { apiClient } from "../../../lib/api-client";
import type { Order, OrderFilters } from "../types";

// Query factory — can be used in hooks AND route loaders
export const ordersQueries = {
  all: () => ["orders"] as const,

  lists: () => [...ordersQueries.all(), "list"] as const,

  list: (filters: OrderFilters = {}) =>
    queryOptions({
      queryKey: [...ordersQueries.lists(), filters],
      queryFn: () => apiClient.get<Order[]>("/orders", { params: filters }),
      staleTime: 30_000,
    }),

  details: () => [...ordersQueries.all(), "detail"] as const,

  detail: (id: string) =>
    queryOptions({
      queryKey: [...ordersQueries.details(), id],
      queryFn: () => apiClient.get<Order>(`/orders/${id}`),
      staleTime: 60_000,
    }),
};
```

**Why factories**: the same `ordersQueries.detail(id)` object can be passed to `useQuery()` in a hook AND to `queryClient.ensureQueryData()` in a route loader — single source of truth for key + fetcher + config.

---

## Pattern: Custom Hooks from Query Factories

Hooks are thin wrappers over query factories. They select/transform data, expose loading state, and provide a clean domain API to components.

```typescript
// src/features/orders/hooks/use-orders.ts
import { useQuery } from "@tanstack/react-query";
import { ordersQueries } from "../api/orders.queries";
import type { OrderFilters } from "../types";

// Hook wraps the query factory — component knows nothing about TanStack internals
export function useOrders(filters: OrderFilters = {}) {
  const { data, isLoading, isError, error } = useQuery(
    ordersQueries.list(filters),
  );

  return {
    orders: data ?? [],
    isEmpty: !isLoading && (data?.length ?? 0) === 0,
    isLoading,
    isError,
    error,
  };
}

// A more specific hook composed from the same factory
export function useOpenOrders() {
  return useOrders({ status: "OPEN" });
}

export function usePendingOrderCount() {
  const { data } = useQuery({
    ...ordersQueries.list({ status: "PENDING" }),
    select: (orders) => orders.length, // transform inside query, component gets a number
  });
  return data ?? 0;
}
```

```typescript
// src/features/orders/hooks/use-place-order.ts
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "../../../lib/api-client";
import { ordersQueries } from "../api/orders.queries";
import type { PlaceOrderInput } from "../types";

export function usePlaceOrder() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: PlaceOrderInput) =>
      apiClient.post<Order>("/orders", input),

    onSuccess: (newOrder) => {
      // Invalidate list, insert new order into cache
      queryClient.invalidateQueries({ queryKey: ordersQueries.lists() });
      queryClient.setQueryData(
        ordersQueries.detail(newOrder.id).queryKey,
        newOrder,
      );
    },
  });
}
```

**Anti-pattern**: fetching data directly inside a component with `useEffect + fetch`. All async state goes through TanStack Query.

---

## Pattern: Route Loaders (TanStack Router)

Route loaders prefetch data before the component renders. They use the same query factories — no duplication.

```typescript
// src/routes/orders/$orderId.tsx
import { createFileRoute } from '@tanstack/react-router'
import { ordersQueries } from '../../features/orders/api/orders.queries'

export const Route = createFileRoute('/orders/$orderId')({
  // Loader runs before component mounts — data is ready on render
  loader: ({ context: { queryClient }, params: { orderId } }) =>
    queryClient.ensureQueryData(ordersQueries.detail(orderId)),

  component: OrderDetailPage,
})

function OrderDetailPage() {
  const { orderId } = Route.useParams()
  // Data is already in cache from loader — no loading state on initial render
  const { data: order } = useSuspenseQuery(ordersQueries.detail(orderId))

  return <OrderDetail order={order} />
}
```

```typescript
// src/routes/__root.tsx — wire queryClient into router context
import { createRootRouteWithContext } from "@tanstack/react-router";
import type { QueryClient } from "@tanstack/react-query";

interface RouterContext {
  queryClient: QueryClient;
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootLayout,
});
```

---

## Pattern: useSuspenseQuery (React 19 + Suspense)

With React 19, use `useSuspenseQuery` instead of `useQuery` wherever you can. Data is always defined, no null checks, errors propagate to error boundaries.

```typescript
// ✅ With Suspense — data is always defined, component is simple
function OrderDetail({ orderId }: { orderId: string }) {
  const { data: order } = useSuspenseQuery(ordersQueries.detail(orderId))
  // order is always Order, never undefined
  return <div>{order.status}</div>
}

// Wrap at route level with Suspense + ErrorBoundary
function OrderDetailPage() {
  return (
    <ErrorBoundary fallback={<OrderError />}>
      <Suspense fallback={<OrderSkeleton />}>
        <OrderDetail orderId={orderId} />
      </Suspense>
    </ErrorBoundary>
  )
}

// ❌ Without Suspense — every component handles loading/error manually
function OrderDetail({ orderId }: { orderId: string }) {
  const { data: order, isLoading, isError } = useQuery(ordersQueries.detail(orderId))
  if (isLoading) return <Skeleton />
  if (isError || !order) return <Error />
  return <div>{order.status}</div>
}
```

---

## Pattern: React 19 — use() Hook for Async

React 19 introduces `use()` for reading promises and context inside render. Use it with Suspense.

```typescript
// Preload a promise (e.g. from a loader or prefetch)
const orderPromise = queryClient.fetchQuery(ordersQueries.detail(id))

// Component reads it with use() — suspends until resolved
function OrderDetail({ promise }: { promise: Promise<Order> }) {
  const order = use(promise)  // React 19
  return <div>{order.status}</div>
}
```

---

## Pattern: React 19 — useOptimistic

For mutations that should feel instant (toggle, status change, reorder):

```typescript
function OrderStatusToggle({ order }: { order: Order }) {
  const updateStatus = useUpdateOrderStatus()
  const [optimisticStatus, setOptimisticStatus] = useOptimistic(order.status)

  async function handleToggle() {
    const next = optimisticStatus === 'OPEN' ? 'CLOSED' : 'OPEN'
    setOptimisticStatus(next)           // instant UI update
    await updateStatus.mutateAsync({ orderId: order.id, status: next })  // real update
  }

  return <button onClick={handleToggle}>{optimisticStatus}</button>
}
```

---

## Pattern: React 19 — useActionState (Forms)

For form submissions, replaces manual loading/error state:

```typescript
import { useActionState } from 'react'

function PlaceOrderForm({ tableId }: { tableId: string }) {
  const placeOrder = usePlaceOrder()

  const [state, formAction, isPending] = useActionState(
    async (_prevState: unknown, formData: FormData) => {
      const items = JSON.parse(formData.get('items') as string)
      await placeOrder.mutateAsync({ tableId, items })
      return { success: true }
    },
    null
  )

  return (
    <form action={formAction}>
      {/* inputs */}
      <button disabled={isPending}>
        {isPending ? 'Placing...' : 'Place Order'}
      </button>
      {state?.success && <p>Order placed!</p>}
    </form>
  )
}
```

---

## Pattern: Optimistic Cache Updates

```typescript
export function useUpdateOrderStatus() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      orderId,
      status,
    }: {
      orderId: string;
      status: OrderStatus;
    }) => apiClient.patch(`/orders/${orderId}/status`, { status }),

    // Optimistic update — update cache before request completes
    onMutate: async ({ orderId, status }) => {
      await queryClient.cancelQueries({
        queryKey: ordersQueries.detail(orderId).queryKey,
      });

      const previous = queryClient.getQueryData<Order>(
        ordersQueries.detail(orderId).queryKey,
      );

      queryClient.setQueryData(
        ordersQueries.detail(orderId).queryKey,
        (old: Order) => ({
          ...old,
          status,
        }),
      );

      return { previous }; // snapshot for rollback
    },

    onError: (_err, { orderId }, context) => {
      // Roll back on error
      queryClient.setQueryData(
        ordersQueries.detail(orderId).queryKey,
        context?.previous,
      );
    },

    onSettled: (_data, _err, { orderId }) => {
      queryClient.invalidateQueries({
        queryKey: ordersQueries.detail(orderId).queryKey,
      });
    },
  });
}
```

---

## Pattern: QueryClient Config

```typescript
// src/lib/query-client.ts
import { QueryClient } from "@tanstack/react-query";

export function createQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000, // 1 min default
        retry: (failureCount, error) => {
          if (error instanceof NotFoundError) return false; // don't retry 404s
          return failureCount < 2;
        },
        refetchOnWindowFocus: false, // adjust per app needs
      },
      mutations: {
        onError: (error) => {
          // Global mutation error handler (toast, log, etc.)
          console.error("Mutation failed:", error);
        },
      },
    },
  });
}
```

---

## Common Smells in React + TanStack Codebases

### [MISPLACED DOMAIN] — Fetch logic inside components

```tsx
// ❌ Component owns async logic
function OrderList() {
  const [orders, setOrders] = useState([]);
  useEffect(() => {
    fetch("/api/orders")
      .then((r) => r.json())
      .then(setOrders);
  }, []);
  return (
    <ul>
      {orders.map((o) => (
        <li key={o.id}>{o.status}</li>
      ))}
    </ul>
  );
}

// ✅ Component is pure UI, hook owns the data
function OrderList() {
  const { orders, isLoading } = useOrders();
  if (isLoading) return <Skeleton />;
  return (
    <ul>
      {orders.map((o) => (
        <li key={o.id}>{o.status}</li>
      ))}
    </ul>
  );
}
```

### [PATTERN INCONSISTENCY] — Inline query keys

```typescript
// ❌ Key defined in 3 different places — cache misses, hard to invalidate
useQuery({ queryKey: ['orders', id], queryFn: ... })
useQuery({ queryKey: ['order', id], queryFn: ... })   // typo
queryClient.invalidateQueries({ queryKey: ['orders'] })

// ✅ All keys from the factory
useQuery(ordersQueries.detail(id))
queryClient.invalidateQueries({ queryKey: ordersQueries.details() })
```

### [HIGH COGNITIVE LOAD] — Prop drilling through 3+ levels

```tsx
// ❌ Passing order state down through Shell → Page → Section → Card
<Shell order={order} onUpdate={handleUpdate} isLoading={isLoading} />;

// ✅ Each component pulls what it needs from a hook
function OrderCard({ orderId }: { orderId: string }) {
  const { data: order } = useSuspenseQuery(ordersQueries.detail(orderId));
  // ...
}
```

### [SHALLOW MODULE] — Hooks that just re-export useQuery

```typescript
// ❌ This hook adds no value
export function useOrder(id: string) {
  return useQuery({ queryKey: ['orders', id], queryFn: () => fetch(...) })
}

// ✅ Hook adds domain value: selects, transforms, hides internals
export function useOrder(id: string) {
  const { data, ...rest } = useQuery(ordersQueries.detail(id))
  return {
    order: data,
    isSettled: data?.status === 'DELIVERED' || data?.status === 'CANCELLED',
    canCancel: data?.status === 'PENDING' || data?.status === 'CONFIRMED',
    ...rest,
  }
}
```

### [INFRA LEAKAGE] — TanStack internals bleeding into components

```tsx
// ❌ Component knows about QueryClient, cache, refetch internals
function OrderCard() {
  const queryClient = useQueryClient()
  const { data } = useQuery(...)
  const handleRefresh = () => queryClient.invalidateQueries(['orders'])
  // ...
}

// ✅ Component calls a hook that hides the implementation
function OrderCard() {
  const { order, refresh } = useOrder(id)  // hook encapsulates invalidation
  // ...
}
```
