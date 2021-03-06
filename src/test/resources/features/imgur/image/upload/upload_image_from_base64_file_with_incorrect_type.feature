# language: ru
@imgur
@image
@upload
@negative
@Link=https://apidocs.imgur.com/#c85c9dfc-7487-4de2-9ecd-66f727cf3139
@Issue=https://link.to.issue.here
Функционал: [Image Upload]

  Структура сценария: Загрузка изображения из base64-файла c указанием некорректного значения параметра "type"
    Когда выполнен POST запрос на URL "imgur.api.image" с headers и parameters из таблицы. Полученный ответ сохранен в переменную "imageUploadResponse"
      | ACCESS_TOKEN  | Authorization | imgur.api.bearer          |
      | BASE64_FILE   | image         | images/testImageLt10.jpg  |
      | MULTIPART     | type          | <type>                    |

    # -------------------------------- При предполагаемой корректной работе API Imgur - эти шаги не должны использоваться -------------------------------- #
    # То есть при указании неверного значения параметра type - изображение не должно быть загружено, соответственно и удалять должно быть нечего
    Затем выполнено сохранение элементов Response из переменной "imageUploadResponse" в соответствии с таблицей
      | BODY_JSON | data.deletehash | hash      |

    Когда выполнен DELETE запрос на URL "imgur.api.image.modify" с headers и parameters из таблицы. Полученный ответ сохранен в переменную "imageDeleteResponse"
      | HEADER  | Authorization | Client-ID {imgur.api.client.id} |
    Тогда ответ Response из переменной "imageDeleteResponse" соответствует условиям из таблицы
      | STATUS    | message | == | HTTP/1.1 200 OK  |
      | BODY_JSON | data    | == | true             |
      | BODY_JSON | success | == | true             |
      | BODY_JSON | status  | == | 200              |
    # -------------------------------- При предполагаемой корректной работе API Imgur - эти шаги не должны использоваться -------------------------------- #

    # TODO @Issue
    # Отсутствует сообщение об ошибке при загрузке base64-файла и указания некорректного значения параметра "type": URL или file
    # Предполагаю, что это можно назвать багом
    Тогда ответ Response из переменной "imageUploadResponse" соответствует условиям из таблицы
      | STATUS    | message             | == | HTTP/1.1 400 Bad Request |
      | BODY_JSON | data.error.message  | == | imgur.error.invalid.type |
      | BODY_JSON | success             | == | false                    |
      | BODY_JSON | status              | == | 400                      |

    Примеры:
      | type  |
      | URL   |
      | file  |