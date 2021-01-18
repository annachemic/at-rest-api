# Проект автоматизации тестирования IMGUR REST API

## Сводка

- [Требования](#Требования)
- [Что нового](#Что-нового)
- [Скачивание и запуск проекта](#Скачивание-и-запуск-проекта)
- [Информация о проекте](#Информация-о-проекте)
    - [Информация по тестам](#Информация-по-тестам)
    - [Информация по отчету Allure](#Информация-по-отчету-Allure)  
- [Автор](#Автор)

## Требования
<a name="Требования"></a>
Для отладки и запуска проекта в среде разработки понадобится:

1. JDK 1.8
2. Maven 3.6.3
3. Установленные плагины IDEA:
    - Gherkin
    - Cucumber for Java
    - Lombok
    
## Что нового
<a name="Что-нового"></a>

Что нового по сравнению с веткой master:  

Техническая часть:
1. Отправка запросов и валидация ответов переделена под работу с RequestSpecification и ResponseSpecification соответственно
2. Реализация формирования спецификаций вынесена из ru.at.rest.api.steps в отдельные классы в ru.at.rest.api.dto.request и ru.at.rest.api.dto.response
3. Добавлены собственные классы, определяющие преобразование данных для отправки запроса/формирования ответа из DataTable: RequestSpecData и ResponseSpecData

Практическая часть:
1. Для спецификации ответа добавлена опция указания типа проверяемого значения
2. Добавлена поддержка использования предпоготовленных спецификаций запроса/ответа:  
- В файле свойств проекта, при наличии записи `prebuild.request.specs = <path>` - будут сформированы спецификации запросов на основе файлов, хранящихся по указанному пути в папке resources  
- В файле свойств проекта, при наличии записи `prebuild.response.specs = <path>` - будут сформированы спецификации ответов на основе файлов, хранящихся по указанному пути в папке resources  

Сформированные спецификации возможно указать как для сценария в целом (будут применяться для всех запросов/ответов сценария):
```
@RequestSpec=BearerAuth
@ResponseSpec=CommonSuccess
```
Так и для отдельного запроса/ответа в частности:
```
Когда выполнен POST запрос на URL "imgur.api.image" с headers и parameters из таблицы. Полученный ответ сохранен в переменную "imageUploadResponse"
  | SPEC      | BearerAuth  |                     |
  | MULTIPART | image       | image.url.lt10      |
  | MULTIPART | title       | initial title       |
  | MULTIPART | description | initial description |
Тогда ответ Response из переменной "imageUploadResponse" соответствует условиям из таблицы
  | SPEC      | UploadSuccess     | -  | none   | none                |
  | BODY_JSON | data.title        | == | string | initial title       |
  | BODY_JSON | data.description  | == | string | initial description |
```

Имя спецификации устанавливается в соответствии с именем файла, из которого спецификация была сформирована.

При описании спецификации возможно использовать вложенность:  
ResponseSpecification UploadSuccess:
```
SPEC      | CommonSuccess   | -  | none   | none
BODY_JSON | data.id         | ~  | string | imgur.correct.image.id
BODY_JSON | data.deletehash | ~  | string | imgur.correct.deletehash
BODY_JSON | data.link       | == | string | imgur.correct.link
```
ResponseSpecification CommonSuccess:
```
STATUS_CODE |               | == | int      | 200
STATUS_LINE |               | == | string   | HTTP/1.1 200 OK
HEADER      | Content-Type  | == | string   | application/json
BODY_JSON   | success       | == | boolean  | true
BODY_JSON   | status        | == | int      | 200
```
Используемые в тесте общие спецификации отображаются в отчете allure в шаге Set up: configureRestAssured [Scenario-Global Specifications](https://drive.google.com/file/d/1S2dPrD1hvD-KKvhwePBHoUZcQb97t-da/view?usp=sharing)  
Используемые в отдельном запросе/ответе спецификации также отображаются в отчете: [Step Specifications](https://drive.google.com/file/d/1HjmRUccOlvpOxmXs10HWC8llTy3nzTJt/view?usp=sharing)

3. Добавлено прикрепление запросов/ответов к соответствующим шагам в allure. Для выключения: ключ -DattachHTTP=false  
4. Сокращен вывод информации в лог файлы (как в общий лог, так и в лог каждого скрипта)
5. Все тесты переработаоны под использование предподготовленных спецификаций запросов/ответов
6. Во всех тестах, при проверке ответа указаны типы проверяемых значений

## Скачивание и запуск проекта
<a name="Скачивание-и-запуск-проекта"></a>
Возможно скачать архив или клонировать проект при наличии git.

[Ссылка на скачивание архива](https://github.com/a-tikhomirov/at-rest-api/archive/lesson4-hw.zip)

Команда для клонирования проекта:

```
$ git clone https://github.com/a-tikhomirov/at-rest-api.git
$ cd at-rest-api/
$ git checkout lesson4-hw
```

Для запуска тестового набора *image* необходимо в командной строке перейти в директорию проекта и выполнить команду:

```
mvn clean test allure:serve
```

Для запуска тестов c заданными тегами необходимо в командной строке перейти в директорию проекта и выполнить команду:

```
mvn clean test -Dcucumber.filter.tags=@tag_to_run allure:serve
```

В результаты выполнения данной команды:
- При необходимости будут скачаны зависимости проекта;
- В однопоточном режиме будут запущен набор тестов по умолчанию (с тегом *image*) или тесты с заданными тегами;
- По окончании тестов будет открыт браузер с отчетом по выполненным тестам.

> Примечание: используется именно однопоточный режим, так как Imgur не всегда нормально
> работает при частой и, тем более, одновременнно отправке множества запросов

## Информация о проекте
<a name="Информация-о-проекте"></a>
### Информация по тестам
<a name="Информация-по-тестам"></a>
> **ВНИМАНИЕ** Imgur API имеет ограничение по числу загружаемых изображений: [не более 50 изображений в час](https://help.imgur.com/hc/en-us/articles/115000083326-What-files-can-I-upload-What-is-the-size-limit-)  
> Поэтому не рекомендуется запускать весь тестовый набор чаще чем раз в час.  
> По этой же причине несколько некритичных тестов были исключены из набора (закомментирован тег @image)

Сценарии тестирования расположены: `src/test/resources/features/`  
Один сценарий тестирования может иметь несколько наборов тестовых данных. Такие сценарии будут запускаться несколько раз (по числу тестовых наборов)  

Тесты, которые, как мне кажется, отражают баги в работе Imgur API помечены тегом `@Issue=...`  
Краткое описание бага указано в сценарии (*.feature* файле) после комментария `#TODO @Issue`  
Такие тесты не проходят (и не должны проходить) так как фунционал, который они проверяют, работает некорректно (на мой взгляд), то есть фактический результат не совпадает с ожидаемым. 

По окончании прохождения тестов будут сформированы логи:
- Единый лог на весь запущенный тестовый набор: `logs/test_log.log`
- Индивидуальный лог для каждого теста: `logs/<дата запуска тестового набора>/features/imgur/image/...`

### Информация по отчету Allure
<a name="Информация-по-отчету-Allure"></a>
Для просмотра отчета по результатам прохождения тестов используется команда: `allure:serve`

Пример отчета: [Allure Overview](https://drive.google.com/file/d/1ACWFvV4DoG-T2MGVSuexWbMX9I9S_RO_/view?usp=sharing)
> Примечание: все упавшие тесты в указанном примере отчета - тесты с багами

В информацию о прохождении теста включается:
- Текущие данные тестового набора - при наличии;
- Ссылка на документацию по тестируемому запросу;
- Отметка о наличии бага (которая должна включать в себя ссылку на заведенный баг) - при наличии;
- Отметки о наличии общих для сценария спецификаций  
- Шаги теста:
  - Данные используемые в отправке запроса/проверке ответа
  - Спецификации используемые в запросе/ответе
  - HTTP запрос/ответ
  - Текст ошибки - при наличии  
- Лог прохождения теста (в шаге Tear down - AttachLogs).

Пример данных отчета по одному тесту: [Allure test view](https://drive.google.com/file/d/1AXPHxO4_x1MS6gTLOm8xMNVsenj9d24s/view?usp=sharing)

## Автор

- **Андрей Тихомиров** - <andrey.tikhomirov.88@gmail.com>