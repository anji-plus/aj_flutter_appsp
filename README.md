# aj_flutter_appsp
# Flutter���� - �汾����
### host����

```
���Windows������C:\Windows\System32\drivers\etc ��host�ļ�����

199.232.4.133 raw.githubusercontent.com

���Mac��������/etc/hosts�¼���
```

### �ڹ���/pubspec.yaml�У�����������

```
aj_flutter_appsp:
    git:
      url: https://github.com/anji-plus/aj_flutter_appsp.git
      ref: ^0.0.1

```
����ref��ʾ�汾������Ӧ�ֿ��tag��
^��ʾ�����°汾�����ָ���汾������Դ˷���

### ��ȡ������ն�����

```
flutter packages get
```

���ߵ�����Ͻ�Packages get

### ����

```
import 'package:aj_flutter_appsp/aj_flutter_appsp_lib.dart';
```

### ���ã���ϸʹ����ο������example��

```
    //����������ʱ���滻����appKey
   String appKey = "24b14615101b4fe0ab9595d6e1d5e428";
   SpRespUpdateModel updateModel =
        await AjFlutterAppSp.getUpdateModel(appKey: appKey);
```

����SpRespUpdateModel�����ֶ���
```
    //apk����/��ת��url
    public String url;
    //�����true����ʾ�ⲿurl������Ϊ��Ҫ��ת����ҳ�������أ�������ת��Ӧ�ñ�����
    //����ֱ����Ӧ���ڲ����أ����صķ�ʽ�����߿����ж��壬Ҳ�ɲο������ṩ��Demo
    public boolean isExternalUrl;
    //�Ƿ���Ҫ����������ʾ��true��ʾ��Ҫ
    public boolean showUpdate;
    // �Ƿ���Ҫǿ�Ƹ��£�true��ʾ��Ҫǿ������ʱ��Ҫ����û�������������������˳�APP
    public boolean mustUpdate;
    //������־
    public String updateLog;
```

# ����-Android ����
### androidĿ¼�£�AndroidManifest.xml�м���Ȩ�ޣ����а���������ʡ��ļ����ʡ�apk��װ��Ȩ��

```
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

### androidĿ¼�£�AndroidManifest.xml�м������provider������Android7.0+�汾����


```
       <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="com.anji.appsp.sdktest.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>
```


���У�file_paths.xml��û���򴴽�����xmlĿ¼�£�file_paths.xml�������£�


```
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path
        name="files_root"
        path="Android/data/����/" />
    <external-path
        name="external_storage_root"
        path="." />
    <root-path
        name="root_path"
        path="" />

</paths>
```

# Flutter���� - ����
### ����

```
import 'package:aj_flutter_appsp/aj_flutter_appsp_lib.dart';
```

### ���ã���ϸʹ����ο������example��
```
    //����������ʱ���滻����appKey
    String appKey = "24b14615101b4fe0ab9595d6e1d5e428";
    SpRespNoticeModel noticeModel =
        await AjFlutterAppSp.getNoticeModel(appKey: appKey);
```
### �������
��Ҫ�ο����弯�����̣��ɲο������ṩ�Ĳ����
������ص�ַ��

[https://github.com/anji-plus/aj_flutter_appsp](https://github.com/anji-plus/aj_flutter_appsp)


