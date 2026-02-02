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
    TextColor(12); // Красный
    PrintText(Text, 1, 4);
    TextColor(15); // Белый
    PrintText(UnicodeString(CurrentString), 2, 4);
    PrintText('Введите число и нажмите Enter, чтобы подтвердить.', 4, 4);
    Ch := ReadKey;
    If (Ord(Ch) >= 48) And (Ord(Ch) <= 57) Then // Цифры
      CurrentString := CurrentString + Ch
    Else If Ch = #13 Then // Enter
    Begin // TODO: добавить проверку на наличие в строке хоть чего-то
      EnterIntegerDialogue := StrToInt(CurrentString);
      Done := True;
    End
    Else If Ch = #8 Then // Backspace
      CurrentString := Copy(CurrentString, 1, Length(CurrentString) - 1);
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
Procedure PushElement; // Вставка
Var
  IntegerToInsert : Integer;
  NewListItem : ^ListItem;
Begin
  ClrScr;
  IntegerToInsert := EnterIntegerDialogue('Вставить элемент.');
  New(NewListItem); // Выделяем память на элемент
  NewListItem^.Data := IntegerToInsert;
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
    TextColor(14); // Жёлтый вроде
    PrintText(UnicodeString(IntToStr(Q.Tail^.Data)), 3, 3);
    TextColor(15);
  End
  Else
  Begin
    PrintText('Очередь пуста!', 2, 3);
    PrintText('Добавьте хотя бы один элемент, чтобы прочитать его.', 3, 3);
  End;
  ReadKey;
End;
Function DeleteElementNoInterface:Integer;
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
  DeleteElementNoInterface := IntegerToReturn;
End;
Procedure PopElement;
Var
  DeletedElement : Integer;
Begin
  ClrScr;
  TextColor(12);
  PrintText('Удалить элемент.', 1, 2);
  TextColor(15);
  If Not EmptyQueue Then
  Begin
    DeletedElement := DeleteElementNoInterface;
    PrintText('Элемент ' + UnicodeString(IntToStr(DeletedElement)) + 
      ' удалён из головы очереди.', 2, 2);
  End
  Else
    PrintText('Нечего удалять, очередь пуста!', 2, 2);
  ReadKey;
End;
Procedure ClearQueue;
Var
  Count : Integer = 0;
Begin
  ClrScr;
  TextColor(12);
  PrintText('Очистить очередь.', 1, 3);
  TextColor(15);
  While Not EmptyQueue Do
  Begin
    DeleteElementNoInterface;
    Count += 1;
  End;
  PrintText('Очередь очищена. Удалено элементов:', 2, 3);
  TextColor(14);
  PrintText(UnicodeString(IntToStr(Count)), 3, 3);
  TextColor(15);
  ReadKey;
End;
Procedure ShowAllElements;
Var
  ElementsString : UnicodeString = '';
  CurrentElement : ^ListItem;
Begin
  ClrScr;
  TextColor(12);
  PrintText('Показать все элементы.', 1, 3);
  TextColor(15);
  If not EmptyQueue Then
  Begin
    PrintText('Все элементы, начиная с головы и заканчивая хвостом:', 2, 3);
    CurrentElement := Q.Head;
    // Если следующий элемент — голова, то мы в хвосте, так что заканчиваем.
    While CurrentElement^.Next <> Q.Head Do
    Begin
      ElementsString += UnicodeString(IntToStr(CurrentElement^.Data));
      ElementsString += ', ';
      CurrentElement := CurrentElement^.Next;
    End;
    ElementsString += UnicodeString(IntToStr(CurrentElement^.Data));
    PrintText(ElementsString, 3, 3);
  End
  Else
  Begin
    PrintText('Очередь пуста!', 2, 3);
    PrintText('Добавьте хотя бы один элемент, чтобы прочитать его.', 3, 3);
  End;
  ReadKey;
End;

{ ПРОЦЕДУРЫ ДЛЯ ВЗАИМОДЕЙСТВИЯ С ПОЛЬЗОВАТЕЛЕМ }

Procedure ExecuteCommand; // Выполнить выбранную в меню команду
Begin // При изменении не забывайте корректировать MenuEntries!
  Case SelectedMenuEntry Of
    1: PushElement;
    2: ReadElement;
    3: PopElement;
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