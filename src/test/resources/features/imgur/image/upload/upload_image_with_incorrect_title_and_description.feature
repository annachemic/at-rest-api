# language: ru
@imgur
@image
@upload
@positive
@Link=https://apidocs.imgur.com/#c85c9dfc-7487-4de2-9ecd-66f727cf3139
@Issue=https://link.to.issue.here
Функционал: [Image Upload]

  Предыстория: Подготовка данных
    Пусть установлено значение переменной "oneSpaceString" равным " "
    И выполнена генерация 256 случайных EN символов и результат сохранен в переменную "seq256Chars"
    И в строке из переменной "seq256Chars" выполнена замена части ".{128}$" на "". Результат сохранен в переменную "first128CharsOfSeq256Chars"

  Структура сценария: Загрузка изображения с указанием некорректных значений параметров "title" и "description"
    Когда выполнен POST запрос на URL "imgur.api.image" с headers и parameters из таблицы. Полученный ответ сохранен в переменную "imageUploadResponse"
      | ACCESS_TOKEN  | Authorization | imgur.api.bearer  |
      | MULTIPART     | image         | image.url.lt10    |
      | MULTIPART     | title         | <title>           |
      | MULTIPART     | description   | <description>     |
    Затем выполнено сохранение элементов Response из переменной "imageUploadResponse" в соответствии с таблицей
      | BODY_JSON | data.id         | imageHash       |
      | BODY_JSON | data.deletehash | imageDeleteHash |

    Когда выполнен GET запрос на URL "imgur.api.image.modify" с headers и parameters из таблицы. Полученный ответ сохранен в переменную "imageGetResponse"
      | HEADER          | Authorization | Client-ID {imgur.api.client.id} |
      | PATH_PARAMETER  | hash          | imageHash                       |
    Тогда ответ Response из переменной "imageGetResponse" соответствует условиям из таблицы
      | STATUS    | message           | ==                | HTTP/1.1 200 OK   |
      | BODY_JSON | data.id           | ==                | imageHash         |
      | BODY_JSON | data.title        | <title-condition> | <expected-title>  |
      | BODY_JSON | data.description  | <desc-condition>  | <expected-desc>   |
      | BODY_JSON | success           | ==                | true              |
      | BODY_JSON | status            | ==                | 200               |

    Когда выполнен DELETE запрос на URL "imgur.api.image.modify" с headers и parameters из таблицы. Полученный ответ сохранен в переменную "imageDeleteResponse"
      | HEADER          | Authorization | Client-ID {imgur.api.client.id} |
      | PATH_PARAMETER  | hash          | imageDeleteHash                 |
    Тогда ответ Response из переменной "imageDeleteResponse" соответствует условиям из таблицы
      | STATUS    | message | == | HTTP/1.1 200 OK  |
      | BODY_JSON | data    | == | true             |
      | BODY_JSON | success | == | true             |
      | BODY_JSON | status  | == | 200              |

    # TODO @Issue
    # При указании некорректных значений параметров "title" и "description" при загрузке изображения (один пробел для title/description или строка длиной более 128 символов для title)
    # в ответе на POST запрос соответствующие элементы (data.title и data.description) содержат не актуальные значения

    # То есть, если передать один пробел в качестве title/description - в ответе на POST - также будет указано значение "один пробел", хотя фактически - эти значения установлены в null.
    # Или, если передать в качестве title строку длиной 256 символов - - в ответе на POST - также будет указано значение в 256 символов, хотя фактически - это значение было урезано до 128 символов
    # Предполагаю, что это можно назвать багом
    Тогда ответ Response из переменной "imageUploadResponse" соответствует условиям из таблицы
      | STATUS    | message           | ==                | HTTP/1.1 200 OK          |
      | BODY_JSON | data.id           | ~                 | imgur.correct.image.id   |
      | BODY_JSON | data.deletehash   | ~                 | imgur.correct.deletehash |
      | BODY_JSON | data.title        | <title-condition> | <expected-title>         |
      | BODY_JSON | data.description  | <desc-condition>  | <expected-desc>          |
      | BODY_JSON | data.link         | ==                | imgur.correct.link       |
      | BODY_JSON | success           | ==                | true                     |
      | BODY_JSON | status            | ==                | 200                      |

    Примеры:
      | title           | title-condition | expected-title              | description     | desc-condition  | expected-desc |
      | oneSpaceString  | null            |                             | oneSpaceString  | null            |               |
      | seq256Chars     | ==              | first128CharsOfSeq256Chars  | seq256Chars     | ==              | seq256Chars   |