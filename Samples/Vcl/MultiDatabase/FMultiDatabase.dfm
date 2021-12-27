object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Form1'
  ClientHeight = 414
  ClientWidth = 726
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 353
    Height = 414
    Align = alLeft
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 55
      Height = 13
      Caption = 'Database 1'
    end
    object edtDatabase1: TEdit
      Left = 16
      Top = 33
      Width = 241
      Height = 21
      TabOrder = 0
      Text = 'DATABASE_1'
    end
    object DBGrid1: TDBGrid
      Left = 1
      Top = 72
      Width = 351
      Height = 341
      Align = alBottom
      DataSource = dsDatabase1
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
    object btnOpenDB1: TButton
      Left = 263
      Top = 31
      Width = 75
      Height = 25
      Caption = 'Open'
      TabOrder = 2
      OnClick = btnOpenDB1Click
    end
  end
  object pnlRight: TPanel
    Left = 353
    Top = 0
    Width = 373
    Height = 414
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 359
    ExplicitTop = 200
    ExplicitWidth = 185
    ExplicitHeight = 41
    object Label2: TLabel
      Left = 24
      Top = 16
      Width = 55
      Height = 13
      Caption = 'Database 2'
    end
    object DBGrid2: TDBGrid
      Left = 1
      Top = 72
      Width = 371
      Height = 341
      Align = alBottom
      DataSource = dsDatabase2
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
    object edtDatabase2: TEdit
      Left = 24
      Top = 33
      Width = 241
      Height = 21
      TabOrder = 1
      Text = 'DATABASE_2'
    end
    object btnOpenDB2: TButton
      Left = 271
      Top = 31
      Width = 75
      Height = 25
      Caption = 'Open'
      TabOrder = 2
      OnClick = btnOpenDB2Click
    end
  end
  object dsDatabase1: TDataSource
    Left = 152
  end
  object dsDatabase2: TDataSource
    Left = 544
  end
end
