object FrameEditLines: TFrameEditLines
  Left = 0
  Top = 0
  Width = 131
  Height = 428
  TabOrder = 0
  object LabelHeight: TLabel
    Left = 9
    Top = 4
    Width = 35
    Height = 13
    Caption = 'Vertical'
  end
  object LabelWidth: TLabel
    Left = 9
    Top = 47
    Width = 48
    Height = 13
    Caption = 'Horizontal'
  end
  object EditVert: TEdit
    Left = 6
    Top = 18
    Width = 91
    Height = 21
    BevelInner = bvNone
    BevelOuter = bvNone
    TabOrder = 0
    Text = '50'
    OnKeyDown = EditKeyDown
  end
  object UpDownVertical: TUpDown
    Left = 97
    Top = 18
    Width = 16
    Height = 21
    Associate = EditVert
    Min = 10
    Position = 50
    TabOrder = 1
    OnChanging = UpDownChanging
  end
  object EditHor: TEdit
    Left = 6
    Top = 61
    Width = 91
    Height = 21
    Align = alCustom
    BevelInner = bvNone
    BevelOuter = bvNone
    TabOrder = 2
    Text = '50'
    OnKeyDown = EditKeyDown
  end
  object UpDownHorizontal: TUpDown
    Left = 97
    Top = 61
    Width = 16
    Height = 21
    Associate = EditHor
    Min = 10
    Position = 50
    TabOrder = 3
    OnChanging = UpDownChanging
  end
end
