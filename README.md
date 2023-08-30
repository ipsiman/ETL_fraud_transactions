## Описание задачи
Реализовать ETL процесс, который получает ежедневные выгрузки данных, загружает их в хранилище данных и строит ежедневные отчеты.

### Обработка файлов
Выгружаемые файлы именуются согласно следующему шаблону:
- `transactions_DDMMYYYY.txt`
- `passport_blacklist_DDMMYYYY.xlsx`
- `terminals_DDMMYYYY.xlsx`

Предполагается, что каждый день поступает только один файл соответствующего формата. После загрузки файла его необходимо переименовать, добавив расширение .backup, чтобы при следующем запуске он не был обработан, и переместить в каталог "archive":
- `transactions_DDMMYYYY.txt.backup`
- `passport_blacklist_DDMMYYYY.xlsx.backup`
- `terminals_DDMMYYYY.xlsx.backup`

### Построение отчета
Ежедневно необходимо строить витрину отчетности о мошеннических операциях на основе загруженных данных. Витрина формируется накоплением, где каждый новый отчет добавляется в ту же таблицу с новой датой отчета (report_dt).

### Признаки мошеннических операций
Мошеннические операции определяются на основе следующих признаков:
- Совершение операции при просроченном или заблокированном паспорте.
- Совершение операции при недействующем договоре.
- Совершение операций в разных городах в течение одного часа.
- Попытка подбора суммы. В течение 20 минут проходит более 3-х операций со следующим шаблоном – каждая последующая меньше предыдущей, при этом отклонены все кроме последней. Последняя операция (успешная) в такой цепочке считается мошеннической.
