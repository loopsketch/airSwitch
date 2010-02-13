1. CreateCertificate.batを編集してください
   AIR SDKの位置やPASSWORDなどの環境変数を環境に合わせて変更してください。
   後に説明するPackageApplication.batでは certificate.pfx というファイルを利用するように書かれていますので、
   そのまま使用するにはCERTIFICATEも変更してください。

2. CreateCertificate.batを実行してcertificate.pfxを作ってください

3. PackageApplication.batを編集してください
   AIR SDKの位置やCERTIFICATEなどの環境変数を環境に合わせて変更してください。

4. CreateCertificate.batを実行してairのパッケージを作成してください
   証明書のパスワードを聞かれますので、CreateCertificate.batで作成したときのパスワードを入力します。



Instructions for DISTRIBUTING* your application:

1. Creating a self-signed certificate:
- edit CreateCertificate.bat to change the path to Flex SDK,
- edit CreateCertificate.bat to set your certificate password (and name if you like),
- run CreateCertificate.bat to generate your self-signed certificate,
- wait a minute before packaging.

2. Packaging the application:
- edit PackageApplication.bat and change the path to Flex SDK,
- if you have a signed certificate, edit PackageApplication.bat to change the path to the certificate,
- run PackageApplication.bat, you will be prompted for the certificate password,
  (note that you may not see '***' when typing your password - it works anyway)
- the packaged application should appear in your project in a new 'air' directory.

* to test your application from FlashDevelop, just press F5 as usual.
