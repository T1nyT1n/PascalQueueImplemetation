Program CircularQueueWithCaseMenu; // Реализация циклической очереди на Pascal
{$codepage UTF-8} // UTF-8 для работы с Unicode (нормальные русские буквы)

Uses 
  Crt, // Для создания case-меню (CRT — Console RunTime).
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
  End;

{ ПЕРЕМЕННЫЕ }

Var
  Q : Queue; // Переменная, которая хранит очередь
  // При изменении не забывайте корректировать ExecuteCommand!
  MenuEntries : Array[1..6] of UnicodeString = (
    '1. Вставить элемент.',
    '2. Прочесть элемент.',
    '3. Удалить элемент.',
    '4. Очистить очередь.',
    '5. Показать все элементы.',
    '6. Выход.'
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
    TextColor(12);
    PrintText(Text, 1, 5);
    TextColor(15);
    PrintText(UnicodeString(CurrentString), 2, 5);
    PrintText('Введите число и нажмите Enter, чтобы подтвердить.', 4, 5);
    PrintText('Нажмите Escape, чтобы отменить.', 5, 5);
    Ch := ReadKey;
    If (Ord(Ch) >= 48) And (Ord(Ch) <= 57) Then
      CurrentString := CurrentString + Ch
    Else If Ch = #13 Then // Enter
    Begin
      EnterIntegerDialogue := StrToInt(CurrentString);
      Done := True;
    End
    Else If Ch = #8 Then // Backspace
      CurrentString := Copy(CurrentString, 1, Length(CurrentString) - 1);
  End;
End;

{ ФУНКЦИИ ДЛЯ ВЗАИМОДЕЙСТВИЯ СО СТРУКТУРОЙ }

Function EmptyQueue:Boolean; // Проверка на наличие элементов
Begin
  If Q.Tail = nil Then
    EmptyQueue := True
  Else
    EmptyQueue := False;
End;
Procedure PushElement; // Вставка
Var
  IntegerToInsert : Integer;
  NewListItem : ^ListItem;
Begin
  ClrScr;
  IntegerToInsert := EnterIntegerDialogue('Вставить элемент.');
  New(NewListItem);
  NewListItem^.Data := IntegerToInsert;
  NewListItem^.Next := nil;
  If EmptyQueue Then
  Begin
    Q.Tail := NewListItem;
    Q.Head := NewListItem;
  End
  Else
  Begin
    Q.Tail^.Next := NewListItem;
    Q.Tail := NewListItem;
  End;
  ClrScr;
  PrintText('Элемент ' + UnicodeString(IntToStr(IntegerToInsert)) + 
    ' вставлен в конец очереди.', 1, 1);
  ReadKey;
End;
Procedure ReadElement; // Вывести элемент на экран
Begin
  ClrScr;
  TextColor(12);
  PrintText('Прочесть элемент.', 1, 3);
  TextColor(15);
  If Not EmptyQueue Then
  Begin
    PrintText('Последний элемент в очереди:', 2, 3);
    PrintText(UnicodeString(IntToStr(Q.Tail^.Data)), 3, 3);
  End
  Else
  Begin
    PrintText('Очередь пуста!', 2, 3);
    PrintText('Добавьте хотя бы один элемент, чтобы прочитать его.', 3, 3);
  End;
  ReadKey;
End;
Procedure DeleteElement;
Var
  OldHead : ListItem;
Begin
  ClrScr;
  TextColor(12);
  PrintText('Удалить элемент.', 1, 2);
  TextColor(15);
  If Not EmptyQueue Then
  Begin
    OldHead := Q.Head^;
    Q.Head := Q.Head^.Next;
    If OldHead.Next = nil Then // На случай если это единственный элемент...
    Begin
      Q.Tail := nil; // ...убираем ещё и хвост, т.к. Head = Tail.
    End;
    PrintText('Элемент ' + UnicodeString(IntToStr(OldHead.Data)) + 
      ' удалён из головы очереди.', 2, 2);
  End
  Else
    PrintText('Нечего удалять, очередь пуста!', 2, 2);
  ReadKey;
End;
Procedure ClearQueue;
Begin
  ClrScr;
  TextColor(12);
  PrintText('Очистить очередь.', 1, 3);
  TextColor(15);
  PrintText('Очередь очищена. Удалено элементов:', 2, 3);
  PrintText('?', 3, 3);
  ReadKey;
End;
Procedure ShowAllElements;
Begin
  ClrScr;
  PrintText('Показать все элементы.', 1, 1);
  ReadKey;
End;

{ ПРОЦЕДУРЫ ДЛЯ ВЗАИМОДЕЙСТВИЯ С ПОЛЬЗОВАТЕЛЕМ }

Procedure ExecuteCommand; // Выполнить выбранную в меню команду
Begin // При изменении не забывайте корректировать MenuEntries!
  Case SelectedMenuEntry Of
    1: PushElement;
    2: ReadElement;
    3: DeleteElement;
    4: ClearQueue;
    5: ShowAllElements;
    6: Quit := True;
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
  CursorOff; // TODO: ДОБАВИТЬ КРОССПЛАТФОРМЕННУЮ ПРОЦЕДУРУ
  SelectedMenuEntry := 1; // В начале выбран первый элемент меню.
  Quit := False;
  While Quit = False Do
  Begin
    ShowMenu;
    MenuKeyboardInput;
  End;
  CursorOn;
End.