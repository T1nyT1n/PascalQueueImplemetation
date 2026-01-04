Program CircularQueueWithCaseMenu; // Реализация циклической очереди на Pascal

Uses Crt; // Для создания case-меню (CRT — Console RunTime).

{ ТИПЫ (мутные) }

Type
  { Заранее создаём тип указателя на следующий элемент списка, чтобы
  компилятор не ругался. }
  NextListItem = ^ListItem;
  ListItem = record // Тип элемента связанного списка.
    Data: Integer;
    Next: NextListItem;
  End;

{ ПЕРЕМЕННЫЕ }

Var
  MenuEntries : Array[1..7] of UnicodeString = (
    '1. Создать очередь.',
    '2. Очистить очередь.',
    '3. Прочесть элемент.',
    '4. Вставить элемент.',
    '5. Удалить элемент.',
    '6. Показать все элементы.',
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
  CenterX := ((WindMaxX - WindMinX + 1) - Length(text)) div 2 + 1;
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

{ ПРОЦЕДУРЫ ДЛЯ ВЗАИМОДЕЙСТВИЯ С ПОЛЬЗОВАТЕЛЕМ }

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
    'q': Quit := True;
    #0: Begin
      Ch := ReadKey; // Читаем «расширенную» клавишу
      Case Ch Of
        #72: MoveSelection(True);
        #80: MoveSelection(False);
      End; // TODO:
    End; // упростить логику,
  End; // а то многовато
End; // что-то вложенности...

{ ФУНКЦИИ ДЛЯ ВЗАИМОДЕЙСТВИЯ СО СТРУКТУРОЙ }

{Function Input():Boolean; // Создать структуру (ввести элементы)
Begin
  ClrScr;
End;
Function Clear():Boolean; // Очистка структуры
Begin
  SetLength(Queue.Data, 1);
  Queue.Head := 0;
  Queue.Tail := 0;
End;
Function Empty():Boolean; // Проверка на наличие элементов
Begin
  If Queue.Head = Queue.Tail Then
  Begin
    Empty := True;
  End;
End;
Function Push(NewItem : Integer):Boolean; // Вставка
Begin
  Queue.Tail := NewItem;
  Push := True;
End;}

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