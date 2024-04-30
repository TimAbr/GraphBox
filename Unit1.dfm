object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 407
  ClientWidth = 662
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 662
    Height = 407
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 408
    ExplicitTop = 216
    ExplicitWidth = 185
    ExplicitHeight = 41
    object PaintBox1: TPaintBox
      Left = 184
      Top = 136
      Width = 449
      Height = 161
      OnClick = PaintBox1Click
    end
  end
end
