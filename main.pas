Program CircularQueueWithCaseMenu; // Реализация циклической очереди на Pascal
{$codepage UTF-8} // UTF-8 для работы с Unicode (нормальные русские буквы)

Uses
  Crt, // Для создания case-меню (CRT — Console RunTime).
  {$IFDEF UNIX}
  CWString,
  {$ENDIF}
  SysUtils;

{ ТИПЫ (мутные) }

Type
  { Заранее создаём тип указателя на следующий элемент списка, чтобы
  компилятор не ругался. }
  NextListItem = ^ListItem;
  ListItem = record // Тип элемента связанного списка.
    Data: Integer;
    Next: NextListItem;
  End;

  { В самом типе очереди нужно хранить начало и конец. И этого достаточно. }
  Queue = record
    Head, Tail : ^ListItem;
    Count : Integer;
  End;

{ ПЕРЕМЕННЫЕ }

Var
  Q : Queue; // Переменная, которая хранит очередь
  // При изменении не забывайте корректировать ExecuteCommand!
  MenuEntries : Array[1..7] of UnicodeString = (
    '1. Вставить элемент.',
    '2. Прочесть элемент.',
    '3. Удалить элемент.',
    '4. Очистить очередь.',
    '5. Показать все элементы.',
    '6. Убрать элементы по условию.',
    '7. Выход.'
  );
  SelectedMenuEntry : Integer; // По умолчанию 0, то есть в начале списка.
  Quit : Boolean; // Не пора ли уже выходить из программы?

{ ПРОЦЕДУРЫ ДЛЯ ВЫВОДА ТЕКСТА НА ЭКРАН }

{ Вывести некоторый текст В СЕРЕДИНЕ ЭКРАНА на одной указанной строке из 
общего их количества. }
Procedure PrintText(Text : UnicodeString; Line : Integer; 
  AmountOfLines : Integer);
Var
  CenterX : Integer;
  CenterY : Integer;
Begin
  { Математика! Считаем не просто середину, а середину за вычетом длины текста
  (для X) или количества строк (для Y). Для X в конце добавляем 1, чтобы 
  перейти к месту, где уже «можно» писать. То есть, начинаем писать не в конце 
  левой границы, а в начале пространства для текста. Для Y всё то же самое — 
  вычисляем, где можно начать, а затем добавляем текущую строку. }
  CenterX := ((WindMaxX - WindMinX + 1) - Length(Text)) div 2 + 1;
  CenterY := ((WindMaxY - WindMinY + 1) - AmountOfLines) div 2 + Line;
  GotoXY(CenterX, CenterY);
  Write(Text);
End;

Procedure ShowMenu; // Отобразить case-меню
Var
  i : Integer;
  EntryText : UnicodeString;
Begin
  ClrScr;
  TextColor(12);
  // +1 компенсирует наличие строки «МЕНЮ» в списке элементов меню
  PrintText('МЕНЮ', 1, Length(MenuEntries) + 1);
  TextColor(15);
  For i := 1 To Length(MenuEntries) Do
  Begin
    If i = SelectedMenuEntry Then // Отрисовка выбранного элемента.
    Begin
      TextColor(14);
      EntryText := '>>> ' + MenuEntries[i] + ' <<<';
    End
    Else // Отрисовка НЕ выбранного элемента.
      EntryText := MenuEntries[i];
    PrintText(EntryText, i + 1, Length(MenuEntries) + 1);
    TextColor(15); // Сбрасываем выделение текста.
  End;
End;

// Показывает диалоговое окно для ввода целого числа.
Function EnterIntegerDialogue(Text: UnicodeString):Integer;
Var
  Done: Boolean;
  CurrentString: String;
  Ch: Char;
Begin
  Done := False;
  CurrentString := '';
  While Done = False Do
  Begin
    ClrScr;
    TextColor(12); // Красный
    PrintText(Text, 1, 4);
    TextColor(15); // Белый
    PrintText(UnicodeString(CurrentString), 2, 4);
    PrintText('Введите число и нажмите Enter, чтобы подтвердить.', 4, 4);
    Ch := ReadKey;
    If (Ord(Ch) >= 48) And (Ord(Ch) <= 57) Then // Цифры
      CurrentString += Ch
    Else If CurrentString = '' Then // Минус можно только в начале строки
    Begin
      If (Ch = #45) Then // Минус
        CurrentString += Ch;
    End
    Else // Enter или Backspace можно только когда уже что-то есть
    Begin
      If Ch = #13 Then // Enter
      Begin
        EnterIntegerDialogue := StrToInt(CurrentString);
        Done := True;
      End
      Else If Ch = #8 Then // Backspace
        CurrentString := Copy(CurrentString, 1, Length(CurrentString) - 1);
    End;
  End;
End;

{ ФУНКЦИИ ДЛЯ ВЗАИМОДЕЙСТВИЯ СО СТРУКТУРОЙ }

Function EmptyQueue:Boolean; // Проверка на наличие элементов
Begin // Проверяем по указателю в переменной очереди.
  If Q.Tail = nil Then // Можно проверять и голову, это не важно.
    EmptyQueue := True
  Else
    EmptyQueue := False;
End;
Function ReadElement:Integer;
Begin
  ReadElement := Q.Head^.Data;
End;

Procedure PushElement(DataToInsert : Integer); // Вставка
Var
  NewListItem : ^ListItem;
Begin
  New(NewListItem); // Выделяем память на элемент
  NewListItem^.Data := DataToInsert;
  { Сразу ссылается на голову, потому что вставляется в конец. Так очередь 
  становится циклической. }
  NewListItem^.Next := Q.Head;
  If EmptyQueue Then // Но если уж очередь пустая...
  Begin
    NewListItem^.Next := NewListItem; // ...то ссылаться приходится на себя.
    Q.Tail := NewListItem;
    Q.Head := NewListItem;
  End
  Else
  Begin
    // Иначе стоит бы ссылку в прошлом хвосте поправить.
    Q.Tail^.Next := NewListItem;
    Q.Tail := NewListItem;
  End;
  Q.Count += 1;
End;

Function PopElement:Integer;
Var
  Temp : ^ListItem;
  IntegerToReturn : Integer;
Begin
  Temp := Q.Head;
  If Q.Tail = Q.Head Then // На случай если это единственный элемент...
  Begin
    Q.Head := nil; // ...обнуляем все указатели.
    Q.Tail := nil; // Так мы убедимся, что вернулись к изначальному состоянию.
  End
  Else
  Begin
    Q.Head := Q.Head^.Next;
    Q.Tail^.Next := Q.Head; // Обязательно нужно обновлять кольцевую связь.
  End;
  IntegerToReturn := Temp^.Data;
  Dispose(Temp); // Удалить из памяти
  Q.Count -= 1;
  PopElement := IntegerToReturn;
End;

Function ClearQueue:Integer;
Var
  ElementsCount : Integer = 0;
Begin
  While Not EmptyQueue Do
  Begin
    PopElement;
    ElementsCount += 1;
  End;
  ClearQueue := ElementsCount;
End;

{ ФУНКЦИИ И ПРОЦЕДУРЫ ДЛЯ ВЫПОЛНЕНИЯ ОПЕРАЦИЙ С ОЧЕРЕДЬЮ ПОЛЬЗОВАТЕЛЕМ }

Procedure PushElementUI;
Var
  IntegerToInsert : Integer;
Begin
  IntegerToInsert := EnterIntegerDialogue('Вставить элемент.');
  PushElement(IntegerToInsert);
  ClrScr;
  PrintText('Элемент ' + UnicodeString(IntToStr(IntegerToInsert)) + 
    ' вставлен в конец очереди.', 1, 1);
  ReadKey; // Ждём, пока пользователь прочитает и нажмёт что-нибудь.
End;

Procedure ReadElementUI; // Вывести элемент на экран
Begin
  ClrScr;
  TextColor(12);
  PrintText('Прочесть элемент.', 1, 3);
  TextColor(15);
  If Not EmptyQueue Then
  Begin
    PrintText('Первый элемент в очереди:', 2, 3);
    TextColor(14); // Жёлтый вроде
    PrintText(UnicodeString(IntToStr(ReadElement)), 3, 3);
    TextColor(15);
  End
  Else
  Begin
    PrintText('Очередь пуста!', 2, 3);
    PrintText('Добавьте хотя бы один элемент, чтобы прочитать его.', 3, 3);
  End;
  ReadKey;
End;

Procedure PopElementUI;
Var
  DeletedElement : Integer;
Begin
  ClrScr;
  TextColor(12);
  PrintText('Удалить элемент.', 1, 2);
  TextColor(15);
  If Not EmptyQueue Then
  Begin
    DeletedElement := PopElement;
    PrintText('Элемент ' + UnicodeString(IntToStr(DeletedElement)) + 
      ' удалён из головы очереди.', 2, 2);
  End
  Else
    PrintText('Нечего удалять, очередь пуста!', 2, 2);
  ReadKey;
End;

Procedure ClearQueueUI;
Var
  Count : Integer;
Begin
  ClrScr;
  TextColor(12);
  PrintText('Очистить очередь.', 1, 3);
  TextColor(15);
  Count := ClearQueue; 
  PrintText('Очередь очищена. Удалено элементов:', 2, 3);
  TextColor(14);
  PrintText(UnicodeString(IntToStr(Count)), 3, 3);
  TextColor(15);
  ReadKey;
End;

Procedure ShowAllElementsUI;
Var
  ElementsString : UnicodeString = '';
  CurrentElement : ^ListItem;
Begin
  ClrScr;
  TextColor(12);
  PrintText('Показать все элементы.', 1, 4);
  TextColor(15);
  If not EmptyQueue Then
  Begin
    PrintText('Все элементы, начиная с головы и заканчивая хвостом:', 2, 4);
    CurrentElement := Q.Head;
    // Если следующий элемент — голова, то мы в хвосте, так что заканчиваем.
    While CurrentElement^.Next <> Q.Head Do
    Begin
      ElementsString += UnicodeString(IntToStr(CurrentElement^.Data));
      ElementsString += ', ';
      CurrentElement := CurrentElement^.Next;
    End;
    ElementsString += UnicodeString(IntToStr(CurrentElement^.Data));
    PrintText(ElementsString, 3, 4);
    PrintText('Всего: ' + UnicodeString(IntToStr(Q.Count)), 4, 4);
  End
  Else
  Begin
    PrintText('Очередь пуста!', 2, 3);
    PrintText('Добавьте хотя бы один элемент, чтобы прочитать его.', 3, 3);
  End;
  ReadKey;
End;

{ Важно: взаимодействует со структурой только с помощью уже готовых процедур
EmptyQueue, ReadElement, PopElement, PushElement и т.д. Они даже специально
были отделены от своих UI частей, чтобы работать внутри этой подпрограммы. }
Procedure RemoveElementsByConditionUI;
Var
  Condition : Char = #0;
  Value : Integer;
  CurrentData : Integer;
  i : Integer;
Begin
  If Not EmptyQueue Then
  Begin
    Value := EnterIntegerDialogue('Введите число для сравнения.');
    ClrScr;
    TextColor(12);
    PrintText('Выберите условие (<, >, =).', 1, 2);
    TextColor(15);
    PrintText('Введите соответствующий символ.', 2, 2);
    While ((Condition <> '<') And (Condition <> '>') And (Condition <> '=')) Do
      Condition := ReadKey;
    // Перебрать все элементы очереди по её длине, потому что мы её не очищаем.
    For i := 1 To Q.Count Do
    Begin
      CurrentData := ReadElement;
      PopElement;
      Case Condition Of
        '<': If (CurrentData >= Value) Then
        Begin
          PushElement(CurrentData);
        End;
        '>': If (CurrentData <= Value) Then
        Begin
          PushElement(CurrentData);
        End;
        '=': If (CurrentData <> Value) Then
        Begin
          PushElement(CurrentData);
        End;
      End;
    End;
    ClrScr;
    PrintText('Очередь обновлена.', 1, 1);
  End
  Else
  Begin
    ClrScr;
    TextColor(12);
    PrintText('Очередь пуста!', 1, 2);
    TextColor(15);
    PrintText('Добавьте хотя бы один элемент.', 2, 2);
  End;
  ReadKey;
End;

{ ПРОЦЕДУРЫ ДЛЯ ВЗАИМОДЕЙСТВИЯ С ПОЛЬЗОВАТЕЛЕМ }

Procedure ExecuteCommand; // Выполнить выбранную в меню команду
Begin // При изменении не забывайте корректировать MenuEntries!
  Case SelectedMenuEntry Of
    1: PushElementUI;
    2: ReadElementUI;
    3: PopElementUI;
    4: ClearQueueUI;
    5: ShowAllElementsUI;
    6: RemoveElementsByConditionUI;
    7: Quit := True;
  End;
End;

// Перемещение выделения элемента меню для навигации по нему.
Procedure MoveSelection(Up : Boolean);
Begin
  If Up = False Then // Опустить выделение вниз.
  Begin
    If SelectedMenuEntry = Length(MenuEntries) Then
      SelectedMenuEntry := 1 // Прыжок из конца в начало
    Else
      SelectedMenuEntry := SelectedMenuEntry + 1;
  End
  Else // Поднять выделение вверх.
  Begin
    If SelectedMenuEntry = 1 Then
      SelectedMenuEntry := Length(MenuEntries) // Прыжок из начала в конец
    Else
      SelectedMenuEntry := SelectedMenuEntry - 1;
  End;
End;

// Считать стрелочки, Enter и т.п. в меню и совершить соответствующее действие.
Procedure MenuKeyboardInput;
Var
  Ch : Char;
Begin
  Ch := ReadKey;
  Case Ch Of
    'q': Quit := True; // Стандартная клавиша выхода из консольных приложений.
    #27: Quit := True; // Ещё одна.
    #13: ExecuteCommand; // Клавиша Enter.
    #0: Begin // #0 — особая клавиша.
      Ch := ReadKey; // Читаем «расширенную» клавишу
      Case Ch Of
        #72: MoveSelection(True);
        #80: MoveSelection(False);
      End; // TODO:
    End; // упростить логику,
  End; // а то многовато
End; // что-то вложенности...

{ ОСНОВНАЯ ПРОГРАММА }
Begin
  Q.Count := 0; // Инициализируем
  CursorOff; // Не работает на Linux, как бы я ни пытался.
  SelectedMenuEntry := 1; // В начале выбран первый элемент меню.
  Quit := False;
  While Quit = False Do
  Begin
    ShowMenu;
    MenuKeyboardInput;
  End;
  ClearQueue; // Очистить память перед выходом.
  CursorOn;
End.