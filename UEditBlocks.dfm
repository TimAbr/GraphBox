object FrameEditBlocks: TFrameEditBlocks
  Left = 0
  Top = 0
  Width = 131
  Height = 482
  TabOrder = 0
  object LabelHeight: TLabel
    Left = 9
    Top = 19
    Width = 58
    Height = 13
    Caption = 'Block Height'
  end
  object LabelWidth: TLabel
    Left = 9
    Top = 62
    Width = 55
    Height = 13
    Caption = 'Block Width'
  end
  object LabelScale: TLabel
    Left = 9
    Top = 108
    Width = 25
    Height = 13
    Caption = 'Scale'
  end
  object EditHeight: TEdit
    Left = 6
    Top = 33
    Width = 91
    Height = 21
    BevelInner = bvNone
    BevelOuter = bvNone
    TabOrder = 0
    Text = '50'
  end
  object UpDownHeight: TUpDown
    Left = 97
    Top = 33
    Width = 16
    Height = 21
    Associate = EditHeight
    Min = 10
    Position = 50
    TabOrder = 1
  end
  object EditWidth: TEdit
    Left = 6
    Top = 76
    Width = 91
    Height = 21
    Align = alCustom
    BevelInner = bvNone
    BevelOuter = bvNone
    TabOrder = 2
    Text = '50'
  end
  object UpDownWidth: TUpDown
    Left = 97
    Top = 76
    Width = 16
    Height = 21
    Associate = EditWidth
    Min = 10
    Position = 50
    TabOrder = 3
  end
  object EditScale: TEdit
    Left = 6
    Top = 122
    Width = 107
    Height = 21
    Align = alCustom
    BevelInner = bvNone
    BevelOuter = bvNone
    TabOrder = 4
    Text = '50'
  end
  object TrackBarScale: TTrackBar
    Left = 6
    Top = 149
    Width = 107
    Height = 20
    Ctl3D = True
    DoubleBuffered = False
    Max = 200
    Min = 50
    ParentCtl3D = False
    ParentDoubleBuffered = False
    Position = 100
    TabOrder = 5
  end
end
