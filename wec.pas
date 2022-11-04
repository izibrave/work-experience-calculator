program WorkExperienceCalculator; { wec version 0.0.1 }

type
    Numtype = integer;
    Date = record
        Day: Numtype;
        Month: Numtype;
        Year: Numtype;
    end;

procedure ReadDate(var Infile: text; var OutDate: Date);
var
    temp: array [1..3] of Numtype;
    cnt: Numtype;
    c: char;
    i: byte;
begin
    for i := 1 to 3 do
    begin
        cnt := 0;
        read(Infile, c);
        while (c <> '.') and (c <> '-') and (c <> #10) do
        begin
            cnt := cnt * 10 + (ord(c) - ord('0'));
            read(Infile, c)
        end;
        temp[i] := cnt
    end;
    OutDate.Day := temp[1];
    OutDate.Month := temp[2];
    OutDate.Year := temp[3]
end;

procedure ReadLine(var Infile: text; var GenSD, GenED: Date);
var
    Temp: Date;
begin
    ReadDate(Infile, Temp);
    GenSD.Day := GenSD.Day + Temp.Day;
    GenSD.Month := GenSD.Month + Temp.Month;
    GenSD.Year := GenSD.Year + Temp.Year;
    ReadDate(Infile, Temp);
    GenED.Day := GenED.Day + Temp.Day;
    GenED.Month := GenED.Month + Temp.Month;
    GenED.Year := GenED.Year + Temp.Year;
end;

procedure CalculateExperience(var PersonExp: Date; GSDate, GEDate: Date);
var
    Temp: Date;
begin
    Temp.Day := GEDate.Day - GSDate.Day;
    Temp.Month := GEDate.Month - GSDate.Month;
    Temp.Year := GEDate.Year - GSDate.Year;
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
    PersonExp := Temp
end;

procedure PrintPersonExperience(var InData: Date);
var
    Temp: string;
    DStr, MStr, YStr: string[2];
begin
    Temp := 'wec: [';
    str(InData.Day, DStr);
    str(InData.Month, MStr);
    str(InData.Year, YStr);
    if InData.Day < 10 then
        Temp := Temp + '0';
    Temp := Temp + DStr + '/';
    if InData.Month < 10 then
        Temp := Temp + '0';
    Temp := Temp + MStr + '/';
    if InData.Year < 10 then
        Temp := Temp + '0';
    Temp := Temp + YStr + ']';
    writeln(output, Temp)
end;

var
    GSDate, GEDate: Date;
    PersonExp: Date;
    Infile: text;
begin
    {$I-}
    if ParamCount() = 0 then
    begin
        writeln(StdErr, 'wec: Expected parameter not found');
        halt(1)
    end;
    if ParamStr(1) = 'version' then
    begin
        writeln(output, 'wec: Version 0.0.1');
        halt(0)
    end;
    if ParamStr(1) = 'template' then
    begin
        writeln(output, 'wec: [Days/Months/Years]');
        halt(0)
    end;
    assign(Infile, ParamStr(1));
    reset(Infile);
    if IOResult <> 0 then
    begin
        writeln(StdErr, 'wec: Failed to open file ', '[', ParamStr(1), ']');
        halt(1)
    end;
    while not SeekEof(Infile) do
        ReadLine(Infile, GSDate, GEDate);
    CalculateExperience(PersonExp, GSDate, GEDate);
    PrintPersonExperience(PersonExp)
end.
