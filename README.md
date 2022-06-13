<p align="center">
  <a href="https://github.com/adrianosantostreina/ADRConnection/blob/README/Images/logo.png">
    <img alt="ADRConnection" src="https://github.com/adrianosantostreina/ADRConnection/blob/README/Images/logo.png">
  </a>
</p>

# ADRConnection
Class to facilitate the creation of Anonymous Threads in your project

## Installation
Just register in the Library Path of your Delphi the path of the SOURCE folder of the library, or if you prefer, you can use Boss (dependency manager for Delphi) to perform the installation:
```
boss install github.com/adrianosantostreina/CustomThread
```

##  ⚡️ Quickstart
The CustomThread unit has a TLib class that implements the CustomThread method. It has the following parameters:

```delphi
class procedure TLib.CustomThread(
      AOnStart, 
      AOnProcess, 
      AOnComplete: TProc; 
      AOnError: TProcedureExcept;
  const ADoCompleteWithError: Boolean
);
```

<ul>
  <li>AOnStart = Processes to run before the main process</li>
  <li>AOnProcess = Main Process</li>
  <li>AOnComplete = Processes to run after the main process</li>
  <li>AOnError = Process to run if errors occur</li>
  <li>ADoCompleteWithError = Fired exception message if error occurs</li>
</ul>

## Use
Declare Loading in the Uses section of the unit where you want to make the call to the class's method.
```delphi
uses
  CustomThread,

```

```delphi
procedure TForm2.Button1Click(Sender: TObject);
begin
  TLib.CustomThread(
    procedure()
    begin
      //Processes to run before the main process
    end,
    procedure()
    begin
      //Main Process
    end,
    procedure()
    begin
      //Processes to run after the main process
    end,
    procedure(const AException: string)
    begin
      //Process to run if errors occur
    end,
    True
  );
end;
```

### Like This

```delphi
[...]
private
    { Private declarations }
    StepUnit: Single;
    Step : Single;
[...]


procedure TForm2.FormCreate(Sender: TObject);
begin
StepUnit := 0;
Step := 0;
recProgress.Width := 0;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
TLib.CustomThread(
procedure()
begin
    //Processes to run before the main process
    StepUnit := (recBack.Width / 10);
    recProgress.Width := Step;
end,
procedure()
begin
    //Main Process
    repeat
    Step := Step + StepUnit;
    TThread.Synchronize(
        TThread.CurrentThread,
        procedure ()
        begin
        Sleep(100);
        recProgress.Width := Step;
        end
    );
    until recProgress.Width >= recBack.Width;
end,
procedure()
begin
    //Processes to run after the main process
    Step := 0;
end,
procedure(const AException: string)
begin
    //Process to run if errors occur
end,
True
);
end;
```

## Video
[![Watch the video](https://github.com/adrianosantostreina/CustomThread/blob/main/viceo1.png)](https://youtu.be/A7VS0XyFFn0?sub_confirmation=1)


## Documentation Languages
[English (en)](https://github.com/adrianosantostreina/ADRConnection/blob/README/README.md)<br>
[Português (ptBR)](https://github.com/adrianosantostreina/ADRConnection/blob/README/README-ptBR.md)<br>

## ⚠️ License
`ADRConnection` is free and open-source library licensed under the [MIT License](https://github.com/adrianosantostreina/ADRConnection/blob/README/LICENSE.md). 