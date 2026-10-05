
## v4.34 — Platform-fee QR + UTR Admin approval
- Added an Admin-configurable UPI ID/display name for Lucky Delivery platform-fee payments.
- Customer payment screen now shows a dynamic UPI QR for the exact locked platform fee when the Admin has configured the UPI ID.
- A customer can pay the QR from another person's UPI phone and submit the resulting UTR/reference number in the app.
- UTR submissions are server-controlled and enter `manual_pending`; customers cannot mark the platform fee as paid themselves.
- Admin Financial screen now lists pending QR/UTR submissions and provides an explicit approval action.
- Admin approval records an audit entry and only then marks the platform fee paid.
- Existing Razorpay payment remains available as the direct in-app gateway option.
- Firestore rules protect platform-fee payment state and manual UTR fields from client-side tampering.
# Low Charge Lucky Delivery — v4.10

## Added in v1.8
- Firebase Phone OTP login flow with role-aware entry for Customer and Delivery Partner.
- OTP verification is required before profile/verification submission.
- Customer and Delivery Partner now have separate verification/login paths.
- Camera/Gallery profile photo selection using `image_picker`.
- Verification status security: client cannot promote an account to `verified` or `rejected`.
- Trusted backend/admin callable `setVerificationStatus` is prepared; it requires Firebase Auth custom claim `admin: true`.
- Firebase Storage rule for each user's profile photo.

## Verification flow
1. Select Customer or Delivery Partner.
2. Enter mobile number and receive OTP.
3. Verify OTP with Firebase Authentication.
4. Complete name, phone and ID last-4 profile fields.
5. Optional profile photo can be selected from camera/gallery.
6. Submit -> `verificationStatus: pending`.
7. Only trusted admin/backend can set `verified` or `rejected`.

## Existing business rules retained
- Delivery charge is negotiated directly between Customer and Delivery Partner; no per-km pricing.
- Final amount = approved product price + agreed delivery charge + ₹2 Lucky Delivery service fee.
- Distance is for navigation/tracking only.
- Customer live/current location is never exposed to Delivery Partner.
- Delivery Partner live location is available only after final acceptance while the order is active.
- Cash, Direct UPI and optional app payment remain supported.
- Payment must be received/confirmed before paid-order completion.

## Production requirements
- Enable Firebase Phone Authentication and configure Android/iOS app settings.
- Run `flutter pub get` after adding `image_picker`.
- Deploy Firestore rules and `storage.rules`.
- Deploy Cloud Functions.
- Configure an authenticated admin workflow/custom claim for verification review.
- Configure App Check and production Firebase security settings.

## Current verification model — Mobile OTP + Live Photo
- Aadhaar verification/e-KYC is intentionally not used.
- Mobile OTP is required for account login.
- User completes a basic profile and captures a live camera photo (gallery selection is not offered in the verification screen).
- A trusted backend callable marks the profile `verified` only after required profile fields and the uploaded live-photo URL are present.
- Suspicious accounts or complaints can still be routed to Admin Review. Admin access uses the Firebase Auth `admin: true` custom claim.
- No Aadhaar number, Aadhaar OTP, PID or government-ID last four digits are stored by this verification flow.


## Added in v2.0 — Admin control & audit
- Admin Verification Review now checks the Firebase Auth custom claim `admin: true` before displaying review cases.
- Rejecting a case requires a reason.
- Every manual approve/reject action is recorded under `users/{uid}/verificationAudit/{auditId}` with Admin UID, action, reason and server timestamp.
- Audit records are read-only from clients and readable only by Admin custom-claim users.
- Admin can review only cases currently in `admin_review`; this prevents re-processing an already finalized case.
- The client still cannot directly set `verified` or `rejected`.

### Production reminder
The `admin: true` custom claim must be assigned only by a trusted server/operator workflow. It must never be granted from the Flutter client. Aadhaar is not part of the current product flow.


## v2.1 Order and payment hardening
- New orders can be created only by a signed-in customer whose profile verificationStatus is `verified`.
- Client-side Firestore updates cannot change customer/partner assignment, negotiation state, final amount, delivery charge, payment, active/finalAccepted flags, or order status.
- Negotiation, final price approval, final assignment, payment confirmation and completion remain Cloud Function controlled.
- Final completion requires payment status `received`.
- Delivery pricing remains negotiated between customer and Delivery Partner; distance is not used to calculate the delivery charge.
- The ₹2 Lucky Delivery platform/service fee remains separate from the negotiated delivery charge.

## Ride Share / Planned Journey

Delivery partners can publish an already-planned trip such as Punasa → Khandwa by bike or car. Users along the route can send an in-app request for a ride. The initial design treats this as journey/seat sharing rather than automatically presenting the service as a taxi or public passenger transport service. Vehicle, passenger, permit, insurance, state transport and aggregator requirements must be checked before production launch in each applicable jurisdiction.

## v2.7 Seat Sharing progress
- Seat Sharing is explicitly a planned-journey feature, not a taxi/cab booking service.
- Delivery pricing remains mutually negotiated between Customer and Delivery Partner; no per-km pricing is imposed.
- Seat Sharing offers can now be published to Firestore from the app when the user is logged in.
- Added initial RideRequest model/repository and Firestore rules for future in-app seat requests.
- Customer/Partner entry screens expose the planned-journey Seat Sharing feature.
- Passenger transport legal/permit/insurance requirements must be checked before production launch; this feature is not represented as a taxi service.


## v3.1 Seat Sharing request hardening
- Seat Sharing requests now use trusted Cloud Functions for create, accept, reject and cancel actions.
- Accepting a request uses a Firestore transaction to decrement available seats and marks an offer `full` when no seats remain.
- Cancelling an accepted request restores the reserved seats; pending cancellation does not change capacity.
- Requester cannot request their own journey. Partner can accept/reject only their own journey's pending requests.
- Firestore clients cannot directly mutate Seat Sharing offers/requests; these state changes are backend-controlled.
- Confirmed Seat Sharing shows a safety reminder to check Aadhaar or another valid government photo ID at pickup; no Aadhaar number/photo is collected or stored by the app.
- Seat Sharing remains a planned-journey/seat-sharing feature, not a per-km taxi fare system.


## v3.2 Seat Sharing confirmation UX
- Journey-owner request list is clearly labelled separately from the user's own requests.
- After acceptance, the journey owner sees an explicit identity-check reminder.
- The requester sees a confirmed-state reminder to check the partner's Aadhaar or valid government photo ID at pickup.
- If a family member is the passenger, the pickup reminder asks the partner to check that passenger's ID too.
- The app still does not collect, upload or store Aadhaar numbers/photos.

## v3.7 Production-hardening update
- Added automatic role-based dashboard routing after successful Mobile OTP: verified users go directly to their Customer/Delivery Partner dashboard; unverified users continue to Profile Verification.
- FCM device-token registration is triggered after successful OTP login so notification infrastructure can be used without exposing tokens to other users.
- Added a real-time Delivery Partner “Available Delivery Orders” list backed by Firestore; partner actions now use the actual order document ID instead of a demo order ID.
- Removed demo order/payment/request actions from the main production navigation so a fake order ID cannot be mistaken for a real transaction.
- Tightened Seat Sharing publication rules so only verified accounts can publish, with journey publication restricted to the Delivery Partner role.
- Tightened ride-request publication to verified accounts.
- Existing rules remain unchanged: negotiated delivery charge (not per-km), separate ₹2 Lucky Delivery fee, customer live-location privacy, active-order partner live tracking, payment-before-completion, and 11-language selection.


## v3.9 hardening update
- Final order acceptance now verifies the caller is actually a `deliveryPartner` and has a verified account; a Customer cannot invoke the acceptance callable to assign an order to themselves.
- Completing an order now removes the Delivery Partner live-tracking document so stale tracking data is not retained as an active tracking point.
- FCM notification sending is now prepared in Cloud Functions for order discussion, offers, agreed price, final price approval, final acceptance, payment selection, payment receipt and delivery completion. Invalid device tokens are cleaned up.
- Device FCM token registration now also follows token refresh events.
- Firebase is initialized at app startup and an FCM background-message handler is registered.
- Payment UI now follows the selected app language for the payment section across all 11 supported languages.
- Customer, Delivery Partner and Create Order screens expose the language selector directly.
- Delivery charge remains mutually agreed between Customer and Delivery Partner; no per-km calculation has been introduced. The ₹2 Lucky Delivery platform/service fee remains separate.

## Validation
- Cloud Functions JavaScript passes `node --check`.
- ZIP archive integrity is checked before Library save.
- Flutter/Dart SDK is not installed in the current build environment, so a real `flutter analyze`/`flutter build` could not be run here.


## v4.8 — Order proof photo removed
- FINAL ACCEPT ORDER no longer requires a live photo.
- Delivery completion no longer requires a live photo.
- Profile/account verification live photo remains a separate verification requirement.



## v4.9 — Localization and configurable platform fee display
- Admin-configured Lucky Delivery platform fee is displayed from the locked order value instead of a hardcoded ₹2 label.
- Core Admin/profile/order-detail screens were made reactive to the selected app language.
- 11-language selector remains supported.

## v4.10 — Admin OTP + Password Login
- Admin Login now provides two options: Mobile Number + OTP and Mobile Number + Password.
- Password login is verified only by a trusted Cloud Function and only for an account carrying the Firebase `admin: true` custom claim.
- Admin passwords are stored only as server-side scrypt-derived hashes; the plaintext password is never stored in Firestore.
- Five consecutive failed password attempts temporarily lock password login for 15 minutes.
- After OTP login, an authorized Admin can set/change the Admin password from the Admin Dashboard.
- `adminCredentials` is blocked from all direct client Firestore reads/writes.
- Existing Admin claim authorization and all marketplace privacy/business rules remain unchanged.

## v4.12 — Razorpay payment security hardening
- Razorpay platform-fee collection now creates the gateway order only from a trusted Cloud Function; the API secret is never shipped in the Flutter client.
- Razorpay Key ID/Key Secret/Webhook Secret are wired as Firebase Functions secrets (`RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET`). Legacy environment variables are supported as a fallback for local/server testing.
- Platform-fee payment verification now checks the Razorpay payment signature and then fetches the payment from Razorpay's server API to verify the gateway order ID, INR currency, exact amount and `captured` status before marking the fee paid.
- Added a signed Razorpay webhook endpoint (`razorpayWebhook`) that handles captured/paid/failed payment events and validates the webhook HMAC before changing an order.
- Gateway orders carry trusted notes containing the Lucky Delivery order ID and platform-fee purpose.
- Repeated webhook delivery is safe/idempotent because the order state is written to the same trusted payment fields.
- The negotiated Delivery Partner amount remains separate from the Lucky Delivery platform fee. The current gateway flow collects only the platform fee into the app's merchant gateway account; cash/direct-UPI/app-payment partner collection remains a separate order-payment step.

### Production payment setup
1. Create/verify the Lucky Delivery merchant account with Razorpay and complete the required business/KYC/bank verification.
2. Create the three Firebase/Secret Manager values: `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, and `RAZORPAY_WEBHOOK_SECRET`.
3. Deploy the Cloud Functions. The deployed callable functions are `createPlatformFeePayment` and `verifyPlatformFeePayment`; the webhook function is `razorpayWebhook`.
4. In Razorpay Dashboard, configure the webhook URL for the deployed `razorpayWebhook` function and use the same webhook secret stored in Firebase Secret Manager.
5. Never place `RAZORPAY_KEY_SECRET` or `RAZORPAY_WEBHOOK_SECRET` inside Flutter code, APK assets, Firestore documents, or Git repositories.

Razorpay's security guidance recommends backend payment verification, signature validation, backend-trusted payment amounts, and HMAC validation for webhooks. See the official Razorpay documentation for the current dashboard/deployment details.


## v4.14 update
Customer payment methods are now Admin-controlled (Cash, Direct UPI, App Payment), with backend enforcement and at least one method required.

## v4.14 Admin Financial Monitoring
- Added Admin-only Payment & Settlement dashboard.
- Server callable `getAdminFinancialSummary` aggregates locked order financial states.
- Shows Lucky Delivery platform fees collected/outstanding, partner delivery amounts, received/pending partner payments, payment-method counts and failed platform-fee payments.
- Does not change customer/partner agreed delivery charges.
- Financial summary is capped at 5,000 order records per request and clearly reports when capped.
- No order live-photo requirement added.


## v4.18 Finalization
- Admin-configured maximum active orders is authoritative for final acceptance; stale partnerCapacity limits no longer reduce the current Admin setting.
- Payment-method notification now reports the agreed Delivery Partner amount rather than the combined final amount.
- App build version bumped to 1.0.0+17.

## v4.19 Production Security Audit
- Firestore user-profile updates now preserve Admin-controlled account and verification review fields; a normal user cannot self-suspend/unblock, alter verification review metadata, or rewrite the verification method/status history.
- Order proof/live-photo requirements remain removed from order acceptance and delivery completion. Profile/account verification live-camera photo remains separate.
- Re-checked Admin-controlled system settings, final acceptance capacity enforcement, payment flow, complaint/dispute authorization, Admin status controls, and Razorpay secret handling.
- No Razorpay secret values are committed to the project; gateway secrets remain server-side configuration.
- Firebase project configuration files and Android release signing are intentionally not embedded in this source archive; they must be supplied/configured for the production Firebase project.
- Local environment did not contain Flutter/Dart/Firebase CLI, so Android APK/AAB compilation and live Firebase deployment were not claimed or performed.


## v4.23 audit/fix
- Fixed missing commas in non-English localization maps after the foreground notification/localization update.
- Re-audited Admin dashboard, financial monitoring, payment lifecycle, and localization files.
- No order live-photo proof flow was reintroduced.
- Customer live/current location privacy and server-side order/payment controls remain unchanged.


## v4.24 changes
- Admin Dashboard is now reactive to the app language selector, with English/Hindi admin labels and fallback support for all 11 language options.
- Admin cancellation now sends FCM notifications to the affected customer and assigned Delivery Partner, while preserving server-side cancellation and capacity release.
- No order live-photo/proof requirement was reintroduced.


## v4.25 privacy and 24-hour order policy
- Customer and Delivery Partner phone numbers are not exposed to each other by default. Order communication is inside the app.
- Users may voluntarily share a personal number in chat at their own responsibility; the app does not disclose the stored profile number automatically.
- The active order window starts at FINAL ACCEPT and lasts 24 hours.
- If an active order is still incomplete after 24 hours, the backend expires it, releases partner capacity, and creates an outstanding ₹10 partner timeout penalty for Admin settlement.
- A scheduled backend job checks overdue active orders every 15 minutes.
- In-app chat messages are stored under the order and are readable only by order participants.
- Production voice calling without exposing phone numbers still requires a configured WebRTC/voice provider and TURN infrastructure; no direct phone dial action is added.

## v4.26 — In-app voice calling foundation
- Added real one-to-one in-app voice calling for active assigned orders using Flutter WebRTC.
- Customer and Delivery Partner call each other through the app; stored profile phone numbers are not used for dialing or exposed by the call feature.
- Voice calls are authorized server-side by `startOrderCall` and are limited to the customer + assigned Delivery Partner while the order is active and within its 24-hour communication window.
- Added incoming-call records and FCM call notification payloads.
- Added Firestore signaling for SDP/ICE candidates and protected call subcollections.
- Added microphone permission configuration for Android/iOS.
- Production TURN configuration is still required for reliable calling across restrictive/mobile networks; current client includes public Google STUN servers only. A TURN provider/server should be configured before public launch.
- Flutter SDK is not available in this build environment, so Flutter compile/build was not claimed. Backend syntax and archive integrity are checked.


v4.27 policy update: after a final-accepted order expires at 24 hours, a customer with at least 3 unanswered Delivery Partner voice-call attempts during that order is automatically suspended. Failed attempts are counted only when a partner-initiated call ends while still ringing; active/answered calls do not count. Customer account status remains Admin-controlled and auditable.


### Voice calling production configuration
- Voice calls use WebRTC with server-authorized ICE configuration.
- Google STUN servers are included by default.
- For reliable calls across restrictive/mobile networks, configure a production TURN service on the backend using `TURN_URL`, `TURN_USERNAME`, and `TURN_CREDENTIAL`.
- Do not place TURN credentials in the Flutter client or commit them to source control.
- For production, prefer short-lived/ephemeral TURN credentials from the TURN provider rather than a permanent shared credential.
- The current source contains the integration hook only; no live TURN credentials are included.
