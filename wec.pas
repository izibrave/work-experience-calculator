program WorkExperienceCalculator; { wec version 0.0.2 }
type
    NumericType = integer;
    Date = record
        Day: NumericType;
        Month: NumericType;
        Year: NumericType;
    end;

procedure CheckParameterCount();
begin
    if ParamCount() = 0 then
    begin
        writeln(StdErr, 'wec: Expected parameter not found');
        halt(1)
    end
end;

procedure PrintVersion();
begin
    writeln(output, 'wec: Version 0.0.2');
    halt(0)
end;

procedure PrintTemplate();
begin
    writeln(output, 'wec: [Days/Months/Years]');
    halt(0)
end;

procedure OpenInputFile(var Infile: text);
begin
    {$I-}
    assign(Infile, ParamStr(1));
    reset(Infile);
    if IOResult <> 0 then
    begin
        writeln(StdErr, 'wec: Failed to open the file');
        halt(1)
    end
end;

procedure CheckReadingSuccess(var Infile: text);
begin
    {$I-}
    if IOResult <> 0 then
    begin
        writeln(StdErr, 'wec: Failed to read data from file');
        close(Infile);
        halt(1)
    end
end;

function IsNumber(c: char): boolean;
begin
    IsNumber := (c >= '0') and (c <= '9')
end;

function IsValidChar(ch: char): boolean;
begin
    IsValidChar := IsNumber(ch) or (ch = #32) or (ch = #10) or (ch = '-') or
        (ch = '.')
end;

procedure CheckCharacter(var Infile: text; ch: char);
begin
    if not IsValidChar(ch) then
    begin
        writeln(StdErr, 'wec: Invalid character was found');
        writeln(StdErr, 'wec: Valid characters: space, line translation,', 
            ' dot, dash and numbers');
        close(Infile);
        halt(1)
    end
end;

procedure ReadDate(var Infile: text; var OutDate: Date);
var
    Temp: array [1..3] of NumericType;
    Storage: NumericType;
    ch: char;
    i: byte;
begin
    for i := 1 to 3 do
    begin
        Storage := 0;
        repeat
            read(Infile, ch);
            CheckCharacter(Infile, ch);
            CheckReadingSuccess(Infile);
        until (ch <> #32) and (ch <> #10);
        while (ch <> '.') and (ch <> '-') and (ch <> #10) do
        begin
            Storage := Storage * 10 + (ord(ch) - ord('0'));
            repeat
                read(Infile, ch);
                CheckCharacter(Infile, ch);
                CheckReadingSuccess(Infile);
            until (ch <> #32)
        end;
        Temp[i] := Storage
    end;
    OutDate.Day := Temp[1];
    OutDate.Month := Temp[2];
    OutDate.Year := Temp[3]
end;

procedure ReadFile(var Infile: text; var GeneralStart, GeneralEnd: Date);
var
    Temp: Date;
begin
    if SeekEof(Infile) then
    begin
        writeln(StdErr, 'wec: This file is empty');
        close(Infile);
        halt(1)
    end;
    while not SeekEof(Infile) do
    begin
        ReadDate(Infile, Temp);
        GeneralStart.Day := GeneralStart.Day + Temp.Day;
        GeneralStart.Month := GeneralStart.Month + Temp.Month;
        GeneralStart.Year := GeneralStart.Year + Temp.Year;
        ReadDate(Infile, Temp);
        GeneralEnd.Day := GeneralEnd.Day + Temp.Day;
        GeneralEnd.Month := GeneralEnd.Month + Temp.Month;
        GeneralEnd.Year := GeneralEnd.Year + Temp.Year;
    end
end;

procedure CalculateExperience(var OutData: Date; GenStart, GenEnd: Date);
var
    Temp: Date;
begin
    Temp.Day := GenEnd.Day - GenStart.Day;
    Temp.Month := GenEnd.Month - GenStart.Month;
    Temp.Year := GenEnd.Year - GenStart.Year;
    while Temp.Day < 0 do
    begin
        Temp.Day := Temp.Day + 30;
        Temp.Month := Temp.Month - 1
    end;
    while Temp.Month < 0 do
    begin
        Temp.Month := Temp.Month + 12;
        Temp.Year := Temp.Year - 1
    end;
    while Temp.Day >= 30 do
    begin
        Temp.Day := Temp.Day - 30;
        Temp.Month := Temp.Month + 1
    end;
    while Temp.Month >= 12 do
    begin
        Temp.Month := Temp.Month - 12;
        Temp.Year := Temp.Year + 1
    end;
    OutData := Temp
end;

procedure BuildString(Number: NumericType; var OutStr: string; Divider: char);
var
    Temp: string[2];
begin
    if Number < 10 then
        OutStr := OutStr + '0';
    str(Number, Temp);
    OutStr := OutStr + Temp + Divider
end;

procedure PrintOutputString(var InputDate: Date);
var
    Temp: string;
begin
    Temp := '[';
    BuildString(InputDate.Day, Temp, '/');
    BuildString(InputDate.Month, Temp, '/');
    BuildString(InputDate.Year, Temp, ']');
    writeln(output, 'wec: ', Temp)
end;

var
    GeneralStart: Date;
    GeneralEnd: Date;
    PersonExperience: Date;
    Infile: text;
begin
    CheckParameterCount();
    case ParamStr(1) of
    'version':
        PrintVersion();
    'template':
        PrintTemplate();
    else
        OpenInputFile(Infile)
    end;
    ReadFile(Infile, GeneralStart, GeneralEnd);
    CalculateExperience(PersonExperience, GeneralStart, GeneralEnd);
    PrintOutputString(PersonExperience)
end.
