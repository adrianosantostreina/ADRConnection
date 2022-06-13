<p align="center">
  <a href="https://github.com/adrianosantostreina/ADRConnection/blob/README/Images/logo.png">
    <img alt="ADRConnection" src="https://github.com/adrianosantostreina/ADRConnection/blob/README/Images/logo.png">
  </a>
</p>

# ADRConnection
Classe para facilitar a criação de Threads Anônimos em seu projeto

## Instalação
Basta cadastrar no Library Path do seu Delphi o caminho da pasta SOURCE da biblioteca, ou se preferir, você pode usar o Boss (gerenciador de dependências do Delphi) para realizar a instalação:
```
boss install github.com/adrianosantostreina/CustomThread
```

## ⚡️ Quickstart
A unit CustomThread tem uma classe TLib que implementa o método CustomThread. Possui os seguintes parâmetros:

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
  <li>AOnStart = Processos a serem executados antes do processo principal</li>
  <li>AOnProcess = Processo principal</li>
  <li>AOnComplete = Processos a serem executados após o processo principal</li>
  <li>AOnError = Processo a ser executado se ocorrerem erros</li>
  <li>ADoCompleteWithError = Mensagem de exceção disparada se ocorrer erro</li>
</ul>

## Usar
Declare CustomThread na seção Uses da unit onde você deseja fazer a chamada para o método da classe.
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

### Exemplo

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
[![Assista ao vídeo](https://github.com/adrianosantostreina/CustomThread/blob/main/viceo1.png)](https://youtu.be/A7VS0XyFFn0?sub_confirmation=1)

## Idiomas da documentação
[Inglês (en)](https://github.com/adrianosantostreina/CustomThread/blob/main/README.md)<br>
[Português (ptBR)](https://github.com/adrianosantostreina/CustomThread/blob/main/README-ptBR.md)<br>

## ⚠️ Licença
`CustomThread` é uma biblioteca gratuita e de código aberto licenciada sob a [Licença MIT](https://github.com/adrianosantostreina/CustomThread/blob/main/LICENSE.md).
