# Lucky Delivery - GitHub APK Build

1. Upload the contents of this package to the root of your GitHub repository.
2. Commit to the `main` branch.
3. Open the **Actions** tab.
4. Select **Build Lucky Delivery APK**.
5. Run the workflow with **Run workflow** if it has not started automatically.
6. When it finishes, open the workflow run and download the `lucky-delivery-debug-apk` artifact.

Important: this produces a **debug/test APK**. Firebase production configuration, Razorpay production secrets, TURN credentials, Android signing, and real-device testing are still required before a public release.
