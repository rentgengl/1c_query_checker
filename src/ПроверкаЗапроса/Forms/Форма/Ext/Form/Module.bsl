﻿//+ Соединение с виртуальной таблицей
//+ Соединение с подзапросом
// Условие с подзапросом
// Получение данных через точку в полях составного типа
//+ В виртуальной таблице нет отборов
//+ Большое число соединений (включая получение реквизитов объектов ссылочного типа)
//+ Соединение не в индексе
//+ Отбор не в индексе
//+ В условии есть ИЛИ


&НаКлиенте
Процедура Проверить(Команда)
	ПроверитьНаСервере();
КонецПроцедуры


&НаСервере
Процедура ПроверитьНаСервере()
	
	Схема = Новый СхемаЗапроса;
	Схема.УстановитьТекстЗапроса(ТекстЗапроса);
	КэшСтруктурыМетаданных = Неопределено;
	РезультатПроверки = ПустаяТаблицаРезультатов();
	
	ПроверитьСхемуНаПападаниеУсловийВИндексы(Схема,РезультатПроверки, КэшСтруктурыМетаданных);
	ПроверитьСхемуНаИспользованиеИЛИ(Схема,РезультатПроверки);
	ПроверитьСхемуНаРаботуСВиртуальнойТаблицей(Схема,РезультатПроверки);
	
	ТекстЗапроса = ТекстЗапросаСРезультатомПроверок(Схема, РезультатПроверки);
	
КонецПроцедуры  

Функция ТекстЗапросаСРезультатомПроверок2(Схема, РезультатПроверки)

	Результат = Схема.ПолучитьТекстЗапроса();
	
	Для Каждого СтрПроверки Из РезультатПроверки Цикл
		Сообщить("ТестовоеСообщение");
		ПакетСхемы = Схема.ПакетЗапросов[СтрПроверки.Пакет];//.Операторы[СтрПроверки.Оператор];
		ЧастьЗапроса = ПакетСхемы.ПолучитьТекстЗапроса();
		ПозицияЗапроса = Найти(Результат,ЧастьЗапроса)-1;
		ТекстДо = Лев(Результат, ПозицияЗапроса);
		ТекстПосле = Прав(Результат, СтрДлина(Результат)-ПозицияЗапроса);
		Результат = СтрШаблон("%1//%2
			|%3", ТекстДо, СтрПроверки.Описание, ТекстПосле);
		
	КонецЦикла;
	Возврат Результат;
	
КонецФункции

#Область РаботаСВиртуальнойТаблицей

Функция ПроверитьСхемуНаРаботуСВиртуальнойТаблицей(Схема,РезультатПроверки)

 	НомерПакета = 0;
	Для Каждого Запрос Из Схема.ПакетЗапросов Цикл

		Если ТипЗнч(Запрос) <> Тип("ЗапросУничтоженияТаблицыСхемыЗапроса") Тогда
			ПроверитьЗапросНаРаботуСВиртуальнойТаблицей(Запрос, РезультатПроверки);
		КонецЕсли;
		
		ДозаполнитьТаблицуЗначением(РезультатПроверки, "Пакет",НомерПакета);
		
		НомерПакета = НомерПакета + 1;
	КонецЦикла;
	
КонецФункции

Процедура ПроверитьЗапросНаРаботуСВиртуальнойТаблицей(ЗапросВыбора, РезультатПроверки)
	// Тестовое сообщение
	Для Каждого ОператорСхемыЗапроса Из ЗапросВыбора.Операторы Цикл
		
		КорневыеИсточники = ОператорСхемыЗапроса.Источники.ПолучитьКорневыеИсточники();
		МассивКорневыхПсевдонимов = Новый Массив();
		Для Каждого КрневойИсточник Из МассивКорневыхПсевдонимов Цикл
			МассивКорневыхПсевдонимов.Добавить(КрневойИсточник.Источник.Псевдоним);	
		КонецЦикла;
		
		Если ОператорСхемыЗапроса.Источники.Количество() > ПорогЧислаСоединений() Тогда
			нСтрока = РезультатПроверки.Добавить();
			нСтрока.Описание = СтрШаблон("Используется %1 соединений, что более %2 разрешенных",ОператорСхемыЗапроса.Источники.Количество(), ПорогЧислаСоединений());			
		КонецЕсли;
		
		Для Каждого Источник Из ОператорСхемыЗапроса.Источники Цикл
			
			ЭтоКорневойИсточник = МассивКорневыхПсевдонимов.Найти(Источник.Источник.Псевдоним) <> Неопределено;
			
			Если ТипЗнч(Источник.Источник) = Тип("ВложенныйЗапросСхемыЗапроса") И Не ЭтоКорневойИсточник Тогда
				нСтрока = РезультатПроверки.Добавить();
				нСтрока.Псевдоним = Источник.Источник.Псевдоним;
				нСтрока.Описание = СтрШаблон("Используется соединение с вложенным запросом %1 ddd", Источник.Источник.Псевдоним);				
			ИначеЕсли ТипЗнч(Источник.Источник) = Тип("ТаблицаСхемыЗапроса") Тогда
				Если ТаблицаЯвляетсяВиртуальной(Источник.Источник.ИмяТаблицы) Тогда
					Если ПараметрыВиртуальнойТаблицыПусты(Источник.Источник.Параметры) Тогда
						нСтрока = РезультатПроверки.Добавить();
						нСтрока.Псевдоним = Источник.Источник.Псевдоним;
						нСтрока.Таблица = Источник.Источник.ИмяТаблицы;
						нСтрока.Описание = СтрШаблон("Отсутствуют параметры в виртуальной таблице %1 %2", 
							Источник.Источник.ИмяТаблицы,
							Источник.Источник.Псевдоним);
					КонецЕсли;

					Если ОператорСхемыЗапроса.Источники.Количество() > 1 Тогда
						нСтрока = РезультатПроверки.Добавить();
						нСтрока.Псевдоним = Источник.Источник.Псевдоним;
						нСтрока.Таблица = Источник.Источник.ИмяТаблицы;
						нСтрока.Описание = СтрШаблон("Используется соединение с виртуальной таблицей %1 %2", 
							Источник.Источник.ИмяТаблицы,
							Источник.Источник.Псевдоним);						
					КонецЕсли;
						
				КонецЕсли;				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти


#Область ИспользованиеИЛИ

Функция ПроверитьСхемуНаИспользованиеИЛИ(Схема,РезультатПроверки)

 	НомерПакета = 0;
	Для Каждого Запрос Из Схема.ПакетЗапросов Цикл

		Если ТипЗнч(Запрос) <> Тип("ЗапросУничтоженияТаблицыСхемыЗапроса") Тогда
			ПроверитьЗапросНаИспользованиеИЛИ(Запрос, РезультатПроверки);
		КонецЕсли;
		
		ДозаполнитьТаблицуЗначением(РезультатПроверки, "Пакет",НомерПакета);
		
		НомерПакета = НомерПакета + 1;
	КонецЦикла;
	
КонецФункции

Процедура ПроверитьЗапросНаИспользованиеИЛИ(ЗапросВыбора, РезультатПроверки)
	
	НормТекстЗапроса = НормализованноеУсловие(ЗапросВыбора.ПолучитьТекстЗапроса());
	ЧислоВхождений = РазложитьСтрокуВМассивПодстрок(НормТекстЗапроса, " ИЛИ ", Истина).Количество()-1;
	Если ЧислоВхождений>0 Тогда
		нСтрока = РезультатПроверки.Добавить();
		нСтрока.Описание = СтрШаблон("В запросе конструкция ИЛИ встречается %1 %2", 
			ЧислоВхождений, 
			?(ЧислоВхождений<4 ИЛИ ЧислоВхождений=1,"раз","раза")
		);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область НастройкаПроверок

Функция ПорогУспешногоПопаданияВИндекс()
	
	Возврат 0.5;
	
КонецФункции

Функция ПорогЧислаСоединений()
	Возврат 8;	
КонецФункции

#КонецОбласти

#Область МетодыДляПроверкиПопаданияОтборовВИндексы

Функция ПроверитьСхемуНаПападаниеУсловийВИндексы(Схема,РезультатПроверки,КэшСтруктурыМетаданных=Неопределено)

    ТаблицаВТ = ПустаяТаблицаВТ();
		
	НомерПакета = 0;
	Для Каждого Запрос Из Схема.ПакетЗапросов Цикл

		Если ТипЗнч(Запрос) <> Тип("ЗапросУничтоженияТаблицыСхемыЗапроса") Тогда
			ПроверитьЗапросНаПопаданиеУсловийВИндексы(Запрос, ТаблицаВТ, РезультатПроверки, КэшСтруктурыМетаданных);
		КонецЕсли;
		
		ДозаполнитьТаблицуЗначением(РезультатПроверки, "Пакет",НомерПакета);
		
		НомерПакета = НомерПакета + 1;
	КонецЦикла;
	
КонецФункции

Процедура ПроверитьЗапросНаПопаданиеУсловийВИндексы(ЗапросВыбора, ТаблицаВТ, РезультатПроверки, КэшСтруктурыМетаданных)
	
	НомерОператора = 0;
	Для Каждого Оператор Из ЗапросВыбора.Операторы Цикл
		ПопаданиеВИндекс_ОператорВыбрать(Оператор, ТаблицаВТ, РезультатПроверки, КэшСтруктурыМетаданных);
		
		ДозаполнитьТаблицуЗначением(РезультатПроверки, "Оператор", НомерОператора);
		
		НомерОператора = НомерОператора + 1;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ЗапросВыбора.ТаблицаДляПомещения) Тогда
		СтрокаВТ = ТаблицаВТ.Добавить();
		СтрокаВТ.ИмяВТ = ЗапросВыбора.ТаблицаДляПомещения;
		СтрокаВТ.ПоляИндекса = МассивПолейИзВыраженияИндекса(ЗапросВыбора.Индекс);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПопаданиеВИндекс_ОператорВыбрать(Оператор, ТаблицаВТ, РезультатПроверки, КэшСтруктурыМетаданных)
	
	ТаблицаИсточников = ПустаяТаблицаИсточников();
	ТаблицаОтборов = ПустаяТаблицаОтборов();

	// Перебор списка источников для заполнения данных проверками
	Для Каждого Источник Из Оператор.Источники Цикл
		ЗаполнитьЗначенияСвойств(ТаблицаИсточников.Добавить(), Источник.Источник);
		Псевдоним = Источник.Источник.Псевдоним;
		ИмяТаблицы = Источник.Источник.ИмяТаблицы;
		
		// Наполнение условий соединения
		Для Каждого Источник Из Оператор.Источники Цикл
			Для Каждого Соединение Из Источник.Соединения Цикл

				ТаблицаСоединения = Соединение.Источник.Источник.Псевдоним;
				Условие = Соединение.Условие;
				ТипСоединения = Строка(Соединение.ТипСоединения);
				МассивУсловий = МассивИЛИ_И(Условие);
				
				Для Каждого МассивИ Из МассивУсловий Цикл
					
					ПоляОтбора = МассивПолейИзУсловия(МассивИ, Псевдоним);
					
					Если ПоляОтбора.Количество()>0 Тогда
						
						СтрОтборов = ПолучитьЗаписьТаблицы(ТаблицаОтборов, Новый Структура("ИмяТаблицы,Псевдоним,ТаблицаСоединения,ТипСоединения",ИмяТаблицы, Псевдоним,ТаблицаСоединения,ТипСоединения));
						ДобавитьЗаписьВМассив(СтрОтборов.ПоляОтбора, ПоляОтбора);  
						                                                                                                                   
					КонецЕсли;
					
				КонецЦикла;
				
			КонецЦикла;
			
		КонецЦикла;
		
		// Наполнение общих условий
		Условия = Оператор.Отбор;
		БазовыеСтрОтборов = ТаблицаОтборов.НайтиСтроки(Новый Структура("ИмяТаблицы,Псевдоним",ИмяТаблицы, Псевдоним));
		УдалятьБазовыйНабор = Ложь;			
		Для Каждого Условие Из Условия Цикл
			
			НормУсловие = НормализованноеУсловие(Условие);
			МассивУсловийИЛИ = МассивИЛИ_И(НормУсловие);
			Для Каждого МассивИ Из МассивУсловийИЛИ Цикл
				
				ПоляОтбора = МассивПолейИзУсловия(МассивИ, Псевдоним); 
							
				Если ПоляОтбора.Количество()>0 Тогда
					УдалятьБазовыйНабор = Истина;
					
					Если БазовыеСтрОтборов.Количество()>0 Тогда
						// Если уже были отборы в соединениях, то добавляем отборы к каждому соединению,
						// Дублирование происходит по каждому условию ИЛИ
						Для Каждого БазовыйСтрОтборов Из БазовыеСтрОтборов Цикл
							СтрОтборов = ТаблицаОтборов.Добавить();
							ЗаполнитьЗначенияСвойств(СтрОтборов, БазовыйСтрОтборов);
							СтрОтборов.ПоляОтбора = КопироватьМассив(БазовыйСтрОтборов.ПоляОтбора);
							ДобавитьЗаписьВМассив(СтрОтборов.ПоляОтбора, ПоляОтбора);
						КонецЦикла;
					Иначе
						СтрОтборов = ТаблицаОтборов.Добавить();
						СтрОтборов.ИмяТаблицы = ИмяТаблицы;
						СтрОтборов.Псевдоним = Псевдоним;
						ДобавитьЗаписьВМассив(СтрОтборов.ПоляОтбора, ПоляОтбора);
					КонецЕсли;
					                                                                                                                   
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЦикла;
		
		Если УдалятьБазовыйНабор = Истина Тогда
			Для Каждого БазовыйСтрОтборов Из БазовыеСтрОтборов Цикл
				ТаблицаОтборов.Удалить(БазовыйСтрОтборов);
			КонецЦикла;
		КонецЕсли;
				
	КонецЦикла;
	
	ТаблицаОтборов.Свернуть("ИмяТаблицы,Псевдоним,ПоляОтбора");
	ПроверитьТаблицуОтборовНаПопаданиеВИндексы(ТаблицаОтборов, ТаблицаВТ, РезультатПроверки, КэшСтруктурыМетаданных)
	
КонецПроцедуры


Процедура ПроверитьТаблицуОтборовНаПопаданиеВИндексы(ТаблицаОтборов, ТаблицаВТ, РезультатПроверки, КэшСтруктурыМетаданных)
	
	Для Каждого ЭлементОтбора Из ТаблицаОтборов Цикл
		
		МетаданныеТаблицы = СтруктураМетаданных(ЭлементОтбора.ИмяТаблицы,КэшСтруктурыМетаданных);
		Если МетаданныеТаблицы = Неопределено Тогда
			ПроверитьИндексИзСпискаВТ(ЭлементОтбора, ТаблицаВТ, РезультатПроверки);
		Иначе
			ПроверитьИндексПоМетаданным(ЭлементОтбора, МетаданныеТаблицы, РезультатПроверки);
		КонецЕсли;
		
	КонецЦикла;

КонецПроцедуры

Процедура ПроверитьИндексИзСпискаВТ(ЭлементОтбора, ТаблицаВТ, РезультатПроверки)
	НайденныеТаблицыВТ = ТаблицаВТ.НайтиСтроки(Новый Структура("ИмяВТ", ЭлементОтбора.ИмяТаблицы));
	
	Для Каждого ЭлементНайденныеТаблицыВТ Из НайденныеТаблицыВТ Цикл
		
		ЧислоСовпадений = 0;
		Для Каждого ПолеИндекса Из ЭлементНайденныеТаблицыВТ.ПоляИндекса Цикл
			Если ЭлементОтбора.ПоляОтбора.Найти(ПолеИндекса) <> Неопределено Тогда
				ЧислоСовпадений = ЧислоСовпадений + 1;
			Иначе
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если ЧислоСовпадений > 0 Тогда
			
			ПроцентПопаданияВИндекс = ЧислоСовпадений / ЭлементНайденныеТаблицыВТ.ПоляИндекса.Количество();
		Иначе
			ПроцентПопаданияВИндекс = 0;
			
		КонецЕсли;
		
		Если ПроцентПопаданияВИндекс < ПорогУспешногоПопаданияВИндекс() Тогда
			
			нСтрока = РезультатПроверки.Добавить();
			нСтрока.Таблица = ЭлементОтбора.ИмяТаблицы;
			нСтрока.Псевдоним = ЭлементОтбора.Псевдоним;
			нСтрока.Описание = СтрШаблон("Отбор попал в индексы таблицы %1 с минимальным процентом - %2. Поля отбора: %3", 
				ЭлементОтбора.ИмяТаблицы, 
				Формат(ПроцентПопаданияВИндекс,"ЧДЦ=0; ЧС=-2; ЧН=; ЧФ=Ч%"),
				СтрСоединить(ЭлементОтбора.ПоляОтбора, ", ")
			);
			
		КонецЕсли;		
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПроверитьИндексПоМетаданным(ЭлементОтбора, МетаданныеТаблицы, РезультатПроверки)
	
	МаксимальныйПроцентПопаданияВИндекс = 0;
	
	Если ЭтоСсылочныйТип(МетаданныеТаблицы.ИмяТаблицы) Тогда
		Если ЭлементОтбора.ПоляОтбора.Найти("Ссылка") <> Неопределено Тогда
			Возврат;
		КонецЕсли;			
	КонецЕсли;
	
	Для Каждого Индекс Из МетаданныеТаблицы.Индексы Цикл
		
		ЧислоСовпадений = 0;
		Для Каждого ПолеИндекса Из Индекс.Поля Цикл
			Если ЭлементОтбора.ПоляОтбора.Найти(ПолеИндекса.ИмяПоля) <> Неопределено Тогда
				ЧислоСовпадений = ЧислоСовпадений + 1;
			Иначе
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если ЧислоСовпадений > 0 Тогда
			
			ПроцентПопаданияВИндекс = ЧислоСовпадений / Индекс.Поля.Количество();
			МаксимальныйПроцентПопаданияВИндекс = Макс(МаксимальныйПроцентПопаданияВИндекс, ПроцентПопаданияВИндекс); 
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если МаксимальныйПроцентПопаданияВИндекс < ПорогУспешногоПопаданияВИндекс() Тогда
		
		нСтрока = РезультатПроверки.Добавить();
		нСтрока.Таблица = ЭлементОтбора.ИмяТаблицы;
		нСтрока.Псевдоним = ЭлементОтбора.Псевдоним;
		нСтрока.Описание = СтрШаблон("Отбор попал в индексы таблицы %1 с минимальным процентом - %2. Поля отбора: %3", 
			ЭлементОтбора.ИмяТаблицы, 
			Формат(МаксимальныйПроцентПопаданияВИндекс,"ЧДЦ=0; ЧС=-2; ЧН=; ЧФ=Ч%"),
			СтрСоединить(ЭлементОтбора.ПоляОтбора, ", ")
		);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область МетодыИнициатизацииНабораДанных

Функция ПустаяТаблицаОтборов()

	ТаблицаВТ = Новый ТаблицаЗначений;
	ТаблицаВТ.Колонки.Добавить("ИмяТаблицы");
	ТаблицаВТ.Колонки.Добавить("Псевдоним");
	ТаблицаВТ.Колонки.Добавить("ТаблицаСоединения");
	ТаблицаВТ.Колонки.Добавить("ТипСоединения");
	ТаблицаВТ.Колонки.Добавить("ПоляОтбора");// массив 

	Возврат ТаблицаВТ;
	
КонецФункции

Функция ПустаяТаблицаИсточников()
	
	ТаблицаИсточников = Новый ТаблицаЗначений;
	ТаблицаИсточников.Колонки.Добавить("ИмяТаблицы");
	ТаблицаИсточников.Колонки.Добавить("Псевдоним");
	
	Возврат ТаблицаИсточников;
	
КонецФункции

Функция ПустаяТаблицаРезультатов()
	
	РезультатПроверки = Новый ТаблицаЗначений;
	РезультатПроверки.Колонки.Добавить("Пакет");
	РезультатПроверки.Колонки.Добавить("Оператор");
	РезультатПроверки.Колонки.Добавить("Таблица");
	РезультатПроверки.Колонки.Добавить("Псевдоним");
	РезультатПроверки.Колонки.Добавить("Описание");
	
	Возврат РезультатПроверки;

КонецФункции

Функция ПустаяТаблицаИндексов()

	ТаблицаВТ = Новый ТаблицаЗначений;
	ТаблицаВТ.Колонки.Добавить("ИмяВТ");
	ТаблицаВТ.Колонки.Добавить("ПоляИндекса");// массив 

	Возврат ТаблицаВТ;
	
КонецФункции

Функция ПустаяТаблицаВТ()
	
	ТаблицаВТ = Новый ТаблицаЗначений;
	ТаблицаВТ.Колонки.Добавить("ИмяВТ");
	ТаблицаВТ.Колонки.Добавить("ПоляИндекса");// массив 
	
	Возврат ТаблицаВТ;
	
КонецФункции

#КонецОбласти

#Область МетодыЗапроса

Функция ПараметрыВиртуальнойТаблицыПусты(ПараметрТаблицыСхемыЗапроса)
	
	ЧислоПараметров = ПараметрТаблицыСхемыЗапроса.Количество();
	Если ЧислоПараметров = 0 Тогда
		Возврат Истина;
	КонецЕсли;
	
	ЗначениеПоследнегоПараметра = ПараметрТаблицыСхемыЗапроса[ЧислоПараметров-1];
	Возврат Строка(ЗначениеПоследнегоПараметра.Выражение) = "";
	
КонецФункции

Функция ТаблицаЯвляетсяВиртуальной(ИмяТаблицы)
	
	ПозицияВторойТочки = СтрНайти(ИмяТаблицы, ".",,,2);
	Если ПозицияВторойТочки = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ИмяВиртуальногоПрефикса = Прав(ИмяТаблицы, СтрДлина(ИмяТаблицы) - ПозицияВторойТочки);
	МассивВиртуальныхПрефиксов = МассивВиртуальныхПрефиксов();
	
	Возврат МассивВиртуальныхПрефиксов.Найти(ИмяВиртуальногоПрефикса) <> Неопределено;
	
	
КонецФункции

Функция МассивВиртуальныхПрефиксов()
	Возврат СтрРазделить("СрезПервых,СрезПоследних,Остатки,Обороты,ОстаткиИОбороты,ОборотыДтКт,ДвиженияССубконто",",");	
КонецФункции

Функция НормализованноеУсловие(Условие)

	Результат = Строка(Условие);
	Результат = СтрЗаменить(Результат, Символы.ПС, " ");
	Результат = СтрЗаменить(Результат, Символы.Таб, " ");
	Результат = СтрЗаменить(Результат, "  ", " ");
	Результат = СтрЗаменить(Результат, "  ", " ");
	Результат = СтрЗаменить(Результат, "  ", " ");
	
	Возврат Результат;
	
КонецФункции

Функция МассивПолейИзУсловия(МассивИ, Псевдоним)

	Результат = Новый Массив;
	Для Каждого Условие Из МассивИ Цикл
		Поле = ПолеИзУсловие(Условие, Псевдоним);
		Если ЗначениеЗаполнено(Поле) Тогда
			Результат.Добавить(Поле);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ПолеИзУсловие(Условие, Псевдоним)
	
	ПозицияПсевдонима = Найти(Условие, Псевдоним + ".");
	Если ПозицияПсевдонима = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ПозицияКонцаПсевдонима = ПозицияПсевдонима  + СтрДлина(Псевдоним)+1;
	Разделители = МассивСимволовРазделенияОператоров();
	
	ПозицияКонцаПоля = СтрДлина(Условие)+1;
	Для Каждого Разделитель Из Разделители Цикл
		ПозицияРазделителя = СтрНайти(Условие, Разделитель,,ПозицияКонцаПсевдонима);
		Если ПозицияРазделителя>0 Тогда
			ПозицияКонцаПоля = Мин(ПозицияКонцаПоля, ПозицияРазделителя);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Сред(Условие, ПозицияКонцаПсевдонима, ПозицияКонцаПоля-ПозицияКонцаПсевдонима); 
	
КонецФункции

Функция МассивСимволовРазделенияОператоров()
	Возврат СтрРазделить(" ,=,<,>,!,.," + Символы.ПС,",",Истина);	
КонецФункции

Функция МассивИ(Условие)

	Возврат РазложитьСтрокуВМассивПодстрок(Условие, " И ");
	
КонецФункции

Функция МассивИЛИ_И(Условие)
	
	Результат = Новый Массив;
	МассивИЛИ = РазложитьСтрокуВМассивПодстрок(Условие, " ИЛИ ");
	Для Каждого ЭлементИЛИ Из МассивИЛИ Цикл
		
		Результат.Добавить(МассивИ(ЭлементИЛИ));
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ТекстСодержитКлючевыеПоля(Текст)
	
	КлючевыеПоля = "ВЫБРАТЬ,ИЗ,ВЫБОР,КОГДА,ТОГДА,ГДЕ,ЛЕВОЕ,ПРАВОЕ,СОЕДИНЕНИЕ,СГРУППИРОВАТЬ,ПО,УПОРЯДОЧИТЬ,ПЕРВЫЕ";
	МассивКлючевыхПолей = СтрРазделить(КлючевыеПоля,",");
	
	Для Каждого КлючевоеПоле Из МассивКлючевыхПолей Цикл
		
		Если Найти(Текст, КлючевоеПоле)>0 Тогда
			Возврат Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Ложь;
	

КонецФункции

Функция МассивПолейИзВыраженияИндекса(ВыражениеИндекса)
	
	Результат = Новый Массив;
	
	Для Каждого СтрИндекса Из ВыражениеИндекса Цикл
		Результат.Добавить(СтрИндекса.Выражение.Псевдоним);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область МетодыМетаданных

Функция СтруктураМетаданных(ИмяОбъекта, Кэш)
	
	Если Кэш <> Неопределено Тогда
		СтрокиКэша = Кэш.НайтиСтроки(Новый Структура("ИмяТаблицы", ИмяОбъекта));
		Если СтрокиКэша.Количество() > 0 Тогда
			Возврат СтрокиКэша[0]; 
		КонецЕсли;
	КонецЕсли;
	
	ОбъектыМетаданных = Новый Массив;
	ОбъектыМетаданных.Добавить(ИмяОбъекта);
	
	Попытка
		Структура = ПолучитьСтруктуруХраненияБазыДанных(ОбъектыМетаданных);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	Если Кэш = Неопределено Тогда
		Кэш = Структура;
	Иначе
		Для Каждого Стр Из Структура Цикл
			ЗаполнитьЗначенияСвойств(Кэш.Добавить(), Стр);
		КонецЦикла;
	КонецЕсли;
	
	Если Структура.Количество() = 0 Тогда
		Возврат Неопределено;
	Иначе
		Возврат Структура[0];
	КонецЕсли;
	
КонецФункции

Функция ЭтоСсылочныйТип(ИмяТаблицы)

	СсылочныеМетаданные = МассивСсылочныхТиповМетаданных();
	Вид = Лев(ИмяТаблицы, СтрНайти(ИмяТаблицы,".")-1);
	
	Возврат СсылочныеМетаданные.Найти(Вид) <> Неопределено;
	
КонецФункции

Функция МассивСсылочныхТиповМетаданных()

	Возврат СтрРазделить("Справочник,Документ,Перечисление,ПланВидовХарактеристик",",");

КонецФункции

#КонецОбласти

#Область ОбщиеМетоды

Функция КопироватьМассив(ИсходныйМассив)
	
	Результат = Новый Массив;
	Для Каждого Элемент Из ИсходныйМассив Цикл
		Результат.Добавить(Элемент);	
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция РазложитьСтрокуВМассивПодстрок(Знач Строка, Знач Разделитель = ",", Знач ПропускатьПустыеСтроки = Неопределено,
										СокращатьНепечатаемыеСимволы = Ложь) Экспорт
	
	Результат = Новый Массив;
	
	// для обеспечения обратной совместимости
	Если ПропускатьПустыеСтроки = Неопределено Тогда
		ПропускатьПустыеСтроки = ?(Разделитель = " ", Истина, Ложь);
		Если ПустаяСтрока(Строка) Тогда 
			Если Разделитель = " " Тогда
				Результат.Добавить("");
			КонецЕсли;
			Возврат Результат;
		КонецЕсли;                                              
	КонецЕсли;
	//
	
	Позиция = Найти(Строка, Разделитель);
	Пока Позиция > 0 Цикл
		Подстрока = Лев(Строка, Позиция - 1);
		Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Подстрока) Тогда
			Если СокращатьНепечатаемыеСимволы Тогда
				Результат.Добавить(СокрЛП(Подстрока));
			Иначе
				Результат.Добавить(Подстрока);
			КонецЕсли;
		КонецЕсли;
		Строка = Сред(Строка, Позиция + СтрДлина(Разделитель));
		Позиция = Найти(Строка, Разделитель);
	КонецЦикла;
	
	Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Строка) Тогда
		Если СокращатьНепечатаемыеСимволы Тогда
			Результат.Добавить(СокрЛП(Строка));
		Иначе
			Результат.Добавить(Строка);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Процедура ДобавитьЗаписьВМассив(ИсходныйМассив, Знач Значение)
	
	Если ИсходныйМассив=Неопределено Тогда
		ИсходныйМассив = Новый Массив;
	КонецЕсли;
	
	Если ТипЗнч(Значение) <> Тип("Массив") Тогда
		Значение = СтрРазделить(Значение,",");
	КонецЕсли;
	
	Для Каждого ЭлементЗначение Из Значение Цикл
		Если ИсходныйМассив.Найти(ЭлементЗначение) = Неопределено Тогда
			ИсходныйМассив.Добавить(ЭлементЗначение);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Процедура ДозаполнитьТаблицуЗначением(Таблица, ИмяПоля, Значение)

		Строки = Таблица.НайтиСтроки(Новый Структура(ИмяПоля));
		Для Каждого Строка Из Строки Цикл
			Строка[ИмяПоля] = Значение;
		КонецЦикла;
		
КонецПроцедуры

Функция ПолучитьЗаписьТаблицы(Таблица, Отбор)

	Строки = Таблица.НайтиСтроки(Отбор);
	
	Если Строки.Количество()>0 Тогда
		Возврат Строки[0];
	Иначе
		нСтрока = Таблица.Добавить();
		ЗаполнитьЗначенияСвойств(нСтрока, Отбор);
		Возврат нСтрока;
	КонецЕсли;
		
КонецФункции


#КонецОбласти
