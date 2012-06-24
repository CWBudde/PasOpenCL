object fMain: TfMain
  Left = 378
  Top = 138
  BorderStyle = bsDialog
  Caption = 'SimpleGL'
  ClientHeight = 487
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnMouseDown = FormMouseDown
  OnMouseUp = FormMouseUp
  PixelsPerInch = 96
  TextHeight = 13
  object tRecalculate: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tRecalculateTimer
    Left = 96
    Top = 80
  end
end
