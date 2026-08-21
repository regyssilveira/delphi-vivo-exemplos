object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'ERP Horizonte - Faturamento'
  ClientHeight = 320
  ClientWidth = 620
  Position = poScreenCenter
  object lblTitulo: TLabel
    Left = 24
    Top = 24
    Width = 304
    Height = 23
    Caption = 'Modernização progressiva do faturamento'
    Font.Height = -19
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnFaturar: TButton
    Left = 24
    Top = 72
    Width = 145
    Height = 33
    Caption = 'Faturar pedido 1'
    TabOrder = 0
    OnClick = btnFaturarClick
  end
  object memResultado: TMemo
    Left = 24
    Top = 128
    Width = 568
    Height = 160
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
end

