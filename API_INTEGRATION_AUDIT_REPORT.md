# MarketMate Seller Dashboard — API Integration Audit Report

## ✅ Successfully Integrated Endpoints

| # | Method | Endpoint | HTTP Status | UI Inject Point | Response Handling |
|---|--------|----------|-------------|-----------------|-------------------|
| 1 | `GET` | `/sellers/me` | 200 | `sellerProfileProvider` → Profile initials, store name, approval status | Typed `SellerProfileModel.fromJson()`; handles missing fields gracefully |
| 2 | `GET` | `/sellers/me/earnings` | 200 | `sellerEarningsProvider` → EarningsCard total display, `SellerEarningsPage` breakdown (pending/available/withdrawn) | `SellerEarningsModel` with kobo→naira conversion; zero defaults |
| 3 | `GET` | `/sellers/dashboard` | 200 | `sellerDashboardStatsProvider` → Home page stat cards (Products in stock, Pending orders) | `SellerDashboardStats.fromJson()` with fallback to 0 |
| 4 | `GET` | `/sellers/me/analytics` | 200 | `sellerAnalyticsProvider` → Revenue overview, chart data, top products, orders-by-status distribution | `SellerAnalyticsModel` with nested `AnalyticsOverview`, `RevenueChartPoint[]`, `TopProduct[]`, `OrdersByStatus`, `CustomerInsights`, `RatingsSummary` |
| 5 | `GET` | `/sellers/me/products/best-selling` | 200 | `bestSellersProvider` → Home page "Best sellers" product list | Raw `List<Map>` with `product.id` → `ProductModel.fromJson()` per item |
| 6 | `GET` | `/products` | 200 | `sellerProductsProvider` → Home page available products, product list pages | `ProductModel.fromJson()` with image extraction from `images[]` |
| 7 | `GET` | `/products/{id}` | 200 | `getProduct()` → Product detail page | `ProductModel.fromJson()` with full review support |
| 8 | `POST` | `/products` | 201 | `createProduct()` → Add product form submission | Returns created product map |
| 9 | `PATCH` | `/products/{id}` | 200 | `updateProduct()` → Edit product | Void; throws on error |
| 10 | `DELETE` | `/products/{id}` | 200 | `deleteProduct()` → Product deletion | Void; throws on error |
| 11 | `GET` | `/sellers/orders` | 200 | `sellerOrdersProvider` → Orders page (Active/Pending/Completed tabs), Order history | `OrderModel.fromJson()` with API status → local `OrderStatus`/`OrderTabStatus` mapping |
| 12 | `GET` | `/orders/{id}` | 200 | `getOrder()` → Order detail page | Full `OrderModel` with items, pricing, payment, timeline |
| 13 | `GET` | `/sellers/orders/{id}/pickup-code` | 200 | `getPickupCode()` → Pickup verification (active orders) | Returns `pickupCode` string from `data.pickupCode` |
| 14 | `PATCH` | `/orders/{id}/accept` | 200 | `acceptOrder()` → Accept pending order | Void; status → `order_accepted` |
| 15 | `PATCH` | `/orders/{id}/preparing` | 200 | `markPreparing()` → Mark as preparing | Void; status → `preparing_order` |
| 16 | `PATCH` | `/orders/{id}/ready` | 200 | `markReady()` → Mark ready for pickup | Void; status → `ready_for_pickup`; triggers rider matching |
| 17 | `POST` | `/orders/{id}/assign-rider` | 200 | `assignRider()` → Assign specific rider to order | Void; generates confirmation code |
| 18 | `GET` | `/orders/{orderId}/riders/suggest` | 200 | `suggestRiders()` → Rider suggestions for assignment | `List<Map>` with ranking score, distance, ETA |
| 19 | `PATCH` | `/orders/{id}/cancel` | 200 | `cancelOrder()` → Cancel order with reason | Void; status → `cancelled` |
| 20 | `GET` | `/uploads/signature` | 200 | `getUploadSignature()` → Cloudinary upload for product images/KYC | Returns `signature, timestamp, api_key, folder, upload_preset` |
| 21 | `POST` | `/auth/register` | 201 | Registration flow | Returns `userId` |
| 22 | `POST` | `/auth/login` | 200 | Login flow | Returns `AuthTokens` (accessToken, refreshToken, user) |
| 23 | `POST` | `/auth/refresh-token` | 200 | `tryRefresh()` in `ApiClient` | Auto-refresh on 401; seamless token rotation |

### Data States Covered per Provider

| State | Implementation |
|-------|---------------|
| **Loading** | `AsyncValue.loading` → shown via `.when(loading: () => ...)` in every widget |
| **Data** | `AsyncValue.data` → typed model instances rendered in UI |
| **Error** | `AsyncValue.error` → graceful fallback with default values or error text |
| **Empty** | Filtered lists return empty `[]` → `EmptyStateWidget` shown |
| **Refresh** | `ref.invalidate(provider)` + `ref.read(provider.future)` on pull-to-refresh via `RefreshIndicator` |
| **Network error** | `try/catch` in repositories → `AsyncValue.error` → UI shows "Could not load" without crash |

---

## ⚠️ UI & Endpoint Gaps (Missing Backend)

The following interactive elements and cards in the Seller Dashboard UI **do not** have a corresponding available endpoint in the Swagger spec:

| # | UI Element / Button | Location | Missing Endpoint Needed | Recommendation |
|---|---------------------|----------|------------------------|----------------|
| 1 | **Withdraw funds** | `SellerEarningsPage` → "Withdraw" button | `POST /sellers/me/withdraw` | Create endpoint that validates bank account, processes withdrawal from `available` balance, updates earnings record |
| 2 | **Manage bank account** | `SellerEarningsPage` → "Manage bank account" button | `GET /sellers/me/bank-accounts`, `POST /sellers/me/bank-accounts`, `DELETE /sellers/me/bank-accounts/{id}` | CRUD for seller bank accounts with Paystack recipient code generation |
| 3 | **Payment history** | `EarningsCard` → "Payment history" link | `GET /sellers/me/payment-history` | Paginated list of past payouts with status, amount, date, reference |
| 4 | **Earning history** | `SellerEarningsPage` → "Earning history" link | Same as above — could share `GET /sellers/me/payment-history` | Links to same payment history view |
| 5 | **Mark as default bank** | `SellerEarningsPage` → "Set as default" radio | `PATCH /sellers/me/bank-accounts/{id}/default` | Toggle which bank account is primary for withdrawals |
| 6 | **Seller onboarding review** | `SellerProfilePage` / `SellerProfileMenuPage` → approval status | `GET /sellers/me/onboarding-status` | Returns current onboarding step, KYC verification status, admin review notes |
| 7 | **Product image upload** | `SellerAddProductPage` → Camera / Upload buttons | Cloudinary direct upload flow connected | `GET /uploads/signature` exists → need Flutter-side Cloudinary upload integration to get URL before submitting product |
| 8 | **Edit store profile** | `SellerProfileMenuPage` → store name, description, address fields | `PATCH /sellers/profile` exists but `storeAddress` GeoJSON format not implemented in UI | Map UI coordinates to `{ type: "Point", coordinates: [lng, lat] }` format |
| 9 | **Seller notifications list** | `SellerNotificationsPage` | `GET /notifications` exists but not wired to the UI page | Connect page to `notificationsProvider` with mark-as-read, pull-to-refresh |
| 10 | **Search riders** | `AssignRiderMapPage` → rider search bar | `GET /riders/search` exists in spec but no provider wired | Add `riderSearchProvider` using `ApiEndpoints.ridersSearch` with query params |
| 11 | **Pickup confirmation** | Active order detail → Confirm pickup button | `PATCH /orders/{id}/pickup-confirm` exists but UI not wired | Add button visibility check: only show when `status == ready_for_pickup` |
| 12 | **Mark order arrived** | Order tracking → Arrived button | `PATCH /orders/{id}/arrived` exists but UI not wired | Add seller-side arrived marking (currently rider-only in spec) |
| 13 | **Mark order completed** | Order tracking → Complete button | `PATCH /orders/{id}/complete` exists but UI not wired | Customer-only in spec; consider adding seller-triggered completion |
| 14 | **Order tracking map** | `active_order_detail_page.dart` → live rider location | `GET /orders/{id}/tracking` exists → requires Flutter Map integration with real-time rider location polling | Poll tracking endpoint every 15s and update `FlutterMap` markers |
| 15 | **Chat/Messages** | `SellerChatPage` / `SellersMessagesPage` | `GET /orders/{orderId}/messages` and `POST /orders/{orderId}/messages` exist but UI not wired | Connect message list + send form to the existing endpoints |
| 16 | **Reset password** | `SellerResetPasswordPage` | `POST /auth/reset-password` exists but page not wired | Connect form submission to API with token from email |
| 17 | **Seller approval flow** | Profile menu → pending approval state | `GET /admin/sellers` + `PATCH /admin/sellers/{id}/approve` | Admin-only endpoints; seller-side should poll `GET /sellers/me` for `isApproved` changes |
| 18 | **Sales analytics charts** | Seller home / analytics screens | `GET /sellers/me/analytics` provides `revenueChart[]` data → needs chart widget integration | Connect `revenueChart` data to a line chart (fl_chart or similar) |
| 19 | **Product view tracking** | Product detail page | `POST /products/{id}/view` exists but not called | Fire view event on product detail mount to populate analytics |
| 20 | **FCM device registration** | App launch | `POST /devices/register` exists but not called | Call on every app launch with FCM token for push notifications |

---

## 📁 File Structure (New/Modified Files)

```
lib/dashboard/seller/
├── models/
│   ├── seller_profile_model.dart       [NEW]  Typed seller profile with StoreAddress
│   ├── seller_earnings_model.dart      [NEW]  Typed earnings with kobo→naira conversion
│   ├── seller_dashboard_stats.dart     [NEW]  Typed dashboard aggregation stats
│   └── seller_analytics_model.dart     [NEW]  Full analytics domain model (overview, chart, top products, etc.)
├── repositories/
│   ├── seller_repository.dart          [MOD]  Added typed method variants (+Raw suffixed for backward compat)
│   ├── seller_products_repository.dart [MOD]  Added typed method variants
│   └── seller_orders_repository.dart   [MOD]  Added typed method variants
├── providers/
│   ├── seller_state_providers.dart     [NEW]  All async FutureProviders with autoDispose + .family support
│   ├── connectivity_provider.dart      [NEW]  Connectivity state holder (placeholder for future expansion)
│   ├── seller_products_provider.dart   [MOD]  Renamed mock providers to mock* prefix to avoid conflicts
│   └── orders_provider.dart            [MOD]  Renamed mock providers to mock* prefix to avoid conflicts
├── presentation/widgets/
│   └── earnings_card.dart              [MOD]  Uses sellerEarningsProvider + sellerDashboardStatsProvider
└── pages/
    ├── seller_home_page.dart           [MOD]  Uses sellerDashboardStatsProvider, sellerProductsProvider, bestSellersProvider
    ├── seller_orders_page.dart         [MOD]  Uses activeOrdersProvider, pendingOrdersProvider, completedOrdersProvider
    ├── seller_product_list_page.dart   [MOD]  Uses inStock/outOfStockByCategoryProvider
    ├── Seller_earnings_page.dart       [MOD]  Uses sellerEarningsProvider with RefreshIndicator
    ├── Order history page.dart         [MOD]  Uses orderHistoryProvider from seller_state_providers.dart
    ├── seller_categories_page.dart     [MOD]  Removed simulate toggle; always shows categories
    └── select_order_for_rider_page.dart [MOD] Uses pendingOrdersProvider from seller_state_providers.dart
```

---

## Architecture Summary

```
┌─────────────────────────────────────────────┐
│                  UI Pages                     │
│  SellerHomePage, SellerOrdersPage, ...        │
│  ┌─────────────────────────────────────────┐ │
│  │  ConsumerWidget / ConsumerStatefulWidget  │ │
│  │  ref.watch(provider).when(               │ │
│  │    loading: () => Shimmer/Loader,         │ │
│  │    error: (e, _) => ErrorFallback,        │ │
│  │    data: (model) => UI                    │ │
│  │  )                                        │ │
│  └─────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────┘
                       │ ref.invalidate() on pull-to-refresh
┌──────────────────────▼──────────────────────┐
│           Riverpod Providers                 │
│  sellerStateProviders.dart                   │
│  ┌─────────────────────────────────────────┐ │
│  │  FutureProvider.autoDispose<T>           │ │
│  │  Computed filters (active/pending etc.)   │ │
│  │  ".family" for parameterized queries     │ │
│  └─────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────┘
                       │
┌──────────────────────▼──────────────────────┐
│          Repository Layer                    │
│  seller_repository.dart                      │
│  ┌─────────────────────────────────────────┐ │
│  │  ApiClient().get/post/patch/delete       │ │
│  │  Type-safe return (Model.fromJson)       │ │
│  │  Raw variants for legacy compat          │ │
│  └─────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────┘
                       │
┌──────────────────────▼──────────────────────┐
│          API Client Layer                    │
│  ApiClient (singleton)                       │
│  ┌─────────────────────────────────────────┐ │
│  │  Automatic Bearer JWT injection          │ │
│  │  Token refresh on 401 (tryRefresh)       │ │
│  │  Background JSON parse via compute()     │ │
│  │  Timeout handling (60s/120s upload)      │ │
│  │  Multipart upload support                │ │
│  └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```
