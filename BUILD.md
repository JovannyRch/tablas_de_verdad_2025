Run app
flutter run --flavor es # Para versión española
flutter run --flavor en # Para versión inglesa

Versión en Español (com.jovannyrch.tablasdeverdad)

flutter build appbundle --flavor es --dart-define=FLAVOR=es

Versión en Inglés (com.jovannyrch.tablasdeverdad.en)

flutter build appbundle --flavor en --dart-define=FLAVOR=en

NOTE

Al publicar en Play Console, asegúrate de subir el archivo generado en build/app/outputs/bundle/esRelease/ para la versión en español y build/app/outputs/bundle/enRelease/ para la versión en inglés.
