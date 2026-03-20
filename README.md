# No Show

**Skip the No-Show, Let It Go! Share Your Spot, Save Your Fee!**

No Show is a peer-to-peer marketplace for offloading booked fitness class spots. When life gets in the way and you can't make your class, No Show lets you pass your spot to someone else — recovering part of your cost instead of eating a no-show fee, while giving someone else a discounted class.

---

## Problem

Boutique fitness classes ($30–40/class) charge steep no-show and late-cancellation fees. Once the cancellation window closes, you either show up or lose your money. Meanwhile, other people would happily take that spot at a discount. There's currently no way for these two sides to find each other.

Studios and platforms like ClassPass have no incentive to solve this — they profit from no-show fees. No Show exists to serve the consumer.

## Solution

No Show connects people who can't make their booked class (listers) with people looking for discounted last-minute spots (buyers). Listers post their spot after the studio's cancellation deadline has passed, and buyers claim it at 50% of the original price. The lister recovers half their cost, and the buyer gets a class at half price.

The spot transfer works via credential sharing — the lister provides their studio login, and the buyer checks in under the lister's account. Credentials are encrypted, held in escrow, and auto-deleted after the class ends.

---

## Target Users

**Primary (supply side):** Boutique fitness regulars who frequently book classes in advance and occasionally can't make them. They're already resigned to losing money and would jump at recovering even half.

**Secondary (demand side):** Cost-conscious fitness enthusiasts who want access to boutique classes but find full-price bookings hard to justify. They're flexible on timing and willing to act fast on last-minute deals.

Every user can both list and buy. There are no separate account types.

---

## Core User Flows

### Listing a Spot

1. User realizes they can't make a booked class (after the studio's cancellation deadline)
2. Opens No Show → taps "List a Class"
3. Enters required info: studio name, class name, date/time, location, class type
4. Enters studio login credentials (encrypted immediately on submission)
5. Optionally adds notes: door code, studio number, parking info, "bring your own mat," etc.
6. App auto-calculates the buyer's price at 50% of the original class cost
7. Listing goes live and push notifications are sent to matched buyers

### Claiming a Spot

1. Buyer receives a push notification or browses the listing feed
2. Views listing details: studio, class, time, location, price, additional notes
3. Taps "Claim This Spot" and confirms payment
4. Studio credentials are decrypted and revealed in-app
5. Buyer attends the class using the lister's credentials
6. After class time, credentials are auto-deleted from the server

### Dashboard

Users see three sections on their dashboard:
- **Upcoming Classes** — spots they've claimed that haven't happened yet
- **Listed Classes** — spots they've posted that are awaiting a buyer
- **Past Classes** — completed transactions (both listed and claimed)

---

## Feature Requirements

### MVP (v1)

**Authentication & Identity**
- Phone number verification required at signup
- Profile with first name and phone number

**Listing Management**
- Create, view, and cancel listings
- Required fields: studio name, class name, date/time, location, class type/category
- Optional fields: additional notes (door code, studio number, parking, etc.), original price paid
- Fixed 50% pricing — auto-calculated, no negotiation
- Listings can only be created after the studio's cancellation deadline
- Listings auto-expire at class start time
- Countdown timer displayed on each listing ("starts in X minutes")

**Discovery & Matching**
- Browsable feed of available spots, filterable by class type, location, and time
- Preference-based push notifications: users set their preferred class types, studios, times, and neighborhood radius
- Search functionality

**Credential Escrow**
- Studio login credentials encrypted with AES-256 at rest
- Encryption keys stored separately from the database
- Credentials revealed in-app only, only after buyer commits
- Never transmitted via email, SMS, or push notification
- Auto-deleted after class ends or if listing expires unclaimed
- Post-transaction prompt reminding listers to change their studio password

**Trust & Safety**
- Liability disclaimer and Terms of Service accepted at signup
- Users acknowledge credential sharing is at their own risk
- Users accept responsibility for any studio ToS violations
- Platform positioned as a facilitator, not a participant
- Strike-based penalty system for listers whose credentials fail or who cancel after selling
- Full refund to buyer if credentials don't work

**Dashboard**
- View upcoming claimed classes, active listings, and past transaction history
- Bottom navigation: Search, Create Listing (+), Home/Dashboard

### v2 (Post-Validation)

- Stripe Connect integration for peer-to-peer payments
- Platform commission on transactions
- User ratings and trust scores
- Dynamic pricing based on time-to-class (closer to start = lower price)
- Sign in with Apple
- In-app messaging (unlocked post-commit)
- Studio partnership integrations for legitimate spot transfers
- Android app

---

## Technical Architecture

### Client
- **Platform:** Native iOS
- **Framework:** SwiftUI
- **Minimum target:** iOS 17

### Backend
- **Supabase** as primary backend-as-a-service
  - PostgreSQL database for users, listings, transactions
  - Built-in auth with phone number (SMS) verification
  - Row-level security policies for data access control
  - Real-time subscriptions for live listing feed updates
  - Edge Functions for server-side logic (credential encryption/decryption, listing expiration, notifications)

### Push Notifications
- OneSignal or Firebase Cloud Messaging, integrated via Supabase Edge Functions
- APNs for iOS delivery

### Credential Security
- AES-256 encryption at rest
- Encryption keys managed via a dedicated secrets manager (e.g., Supabase Vault or AWS Secrets Manager), stored separately from the application database
- Credentials decrypted server-side and delivered over HTTPS to the client only upon buyer commitment
- Automatic server-side deletion triggered by class end time (via scheduled Edge Function)

### Future Infrastructure
- Stripe Connect for payments (build integration scaffolding early)
- Analytics (Mixpanel or PostHog) for tracking listing/claim conversion rates

---

## Data Model (Core Entities)

**User**
- id, phone_number, first_name, created_at
- notification_preferences (class types, studios, times, radius)

**Listing**
- id, lister_id (FK → User), studio_name, class_name, class_type
- date_time, location, original_price, asking_price
- encrypted_credentials, additional_notes
- status (active | claimed | expired | cancelled)
- created_at, expires_at

**Transaction**
- id, listing_id (FK → Listing), buyer_id (FK → User)
- amount, status (pending | completed | refunded | disputed)
- credentials_revealed_at, credentials_deleted_at
- created_at

**Strike**
- id, user_id (FK → User), transaction_id (FK → Transaction)
- reason, created_at

---

## Go-to-Market

### Launch Strategy
- Hyper-local: one city neighborhood with high boutique fitness density
- Concentrate all efforts on building supply-side density in that area before expanding

### User Acquisition (MVP Phase)
- Organic social media targeting local fitness communities
- Local Facebook groups, Reddit fitness communities, Nextdoor
- Content marketing around the pain point (e.g., "Just lost $30 on a class I couldn't make")
- Seed early listings personally to demonstrate the experience and populate the feed

### Growth Levers (Post-MVP)
- Referral program (invite a friend, both benefit)
- Guerilla marketing at studios (flyers in changing rooms)
- Local fitness influencer partnerships

---

## Key Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Studios ban users for credential sharing | Medium | Liability waiver; user assumes risk. At scale, pivot to legitimate studio partnerships. |
| Credential data breach | High | AES-256 encryption at rest, separate key storage, auto-deletion post-class, HTTPS-only delivery. |
| Low marketplace liquidity | High | Hyper-local launch for density, seed listings, strong push notification system. |
| Legal action from studios | Low at MVP scale | ToS + liability disclaimer. Consult a lawyer before launch. Pivot model if this becomes a real threat at scale. |
| Buyer arrives and credentials fail | Medium | Full buyer refund, lister strike penalty, post-class credential deletion. |
| Tight matching window limits conversions | Medium | Push notifications, countdown timers, preference-based alerts to surface listings fast. |

---

## Success Metrics

**Supply**
- Number of listings created per week
- Listing-to-claim conversion rate
- Average time from listing creation to claim

**Demand**
- Number of active buyers (notification preferences set)
- Push notification open rate and claim-through rate

**Trust**
- Credential failure rate (% of transactions where credentials didn't work)
- Strike rate (% of listers flagged)
- Refund rate

**Growth**
- Weekly active users
- Repeat usage (users who list or buy more than once)
- Organic referral rate

---

## Open Questions

- [ ] What specific neighborhood are we launching in?
- [ ] What are the exact strike thresholds? (e.g., 3 strikes = temporary ban, 5 = permanent?)
- [ ] At what transaction volume or user count do we introduce payments?
- [ ] Should the 50% split be dynamic based on proximity to class start time?
- [ ] What's the legal structure? (LLC, etc.) Lawyer consultation needed pre-launch.
- [ ] What's the policy if a lister wants to cancel a listing before a buyer claims it?
- [ ] Should we support class packages/memberships or only single-class bookings?
