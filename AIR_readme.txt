1. CreateCertificate.bat��ҏW���Ă�������
   AIR SDK�̈ʒu��PASSWORD�Ȃǂ̊��ϐ������ɍ��킹�ĕύX���Ă��������B
   ��ɐ�������PackageApplication.bat�ł� certificate.pfx �Ƃ����t�@�C���𗘗p����悤�ɏ�����Ă��܂��̂ŁA
   ���̂܂܎g�p����ɂ�CERTIFICATE���ύX���Ă��������B

2. CreateCertificate.bat�����s����certificate.pfx������Ă�������

3. PackageApplication.bat��ҏW���Ă�������
   AIR SDK�̈ʒu��CERTIFICATE�Ȃǂ̊��ϐ������ɍ��킹�ĕύX���Ă��������B

4. CreateCertificate.bat�����s����air�̃p�b�P�[�W���쐬���Ă�������
   �ؖ����̃p�X���[�h�𕷂���܂��̂ŁACreateCertificate.bat�ō쐬�����Ƃ��̃p�X���[�h����͂��܂��B



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
