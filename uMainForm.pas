unit uMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Effects, FMX.Controls.Presentation, FMX.Objects, FMX.Colors,
  FMX.ListBox, FMX.Layouts, FMX.DialogService.Async, FMX.Edit,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  REST.Types, REST.Client, REST.Response.Adapter, Data.Bind.Components,
  Data.Bind.ObjectScope, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, FMX.ExtCtrls,
  FMX.TabControl, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FireDAC.Stan.StorageBin,
  System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.DBScope;

type
  TMainForm = class(TForm)
    MaterialOxfordBlueSB: TStyleBook;
    ToolBar1: TToolBar;
    Label1: TLabel;
    ShadowEffect1: TShadowEffect;
    ScreenshotButton: TButton;
    SaveDialog1: TSaveDialog;
    APIKeyEdit: TEdit;
    APIKeyButton: TButton;
    GenerateButton: TButton;
    Timer1: TTimer;
    FDMemTable2: TFDMemTable;
    RESTResponse2: TRESTResponse;
    RESTResponseDataSetAdapter2: TRESTResponseDataSetAdapter;
    RESTClient2: TRESTClient;
    RESTRequest2: TRESTRequest;
    FDMemTable1: TFDMemTable;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    ProgressBar: TProgressBar;
    TemplateMemo: TMemo;
    Layout1: TLayout;
    Label2: TLabel;
    PromptMemo: TMemo;
    Label5: TLabel;
    NegativePromptEdit: TEdit;
    NetHTTPClient1: TNetHTTPClient;
    Timer2: TTimer;
    TabControl: TTabControl;
    ObjectTabItem: TTabItem;
    ViewTabItem: TTabItem;
    ImageViewer: TImageViewer;
    PreviewImage: TImage;
    Layout2: TLayout;
    ListView1: TListView;
    FileMemTable: TFDMemTable;
    ImagePathEdit: TEdit;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    LinkControlToField1: TLinkControlToField;
    StatusBar1: TStatusBar;
    Img2ImgLayout: TLayout;
    Layout3: TLayout;
    ImageEdit: TEdit;
    OpenButton: TButton;
    Label6: TLabel;
    ScaleLabel: TLabel;
    ScaleTB: TTrackBar;
    SourceImage: TImage;
    OpenDialog: TOpenDialog;
    Label7: TLabel;
    Layout7: TLayout;
    Label16: TLabel;
    WidthEdit: TEdit;
    HeightEdit: TEdit;
    PaintLayout: TLayout;
    ProductSizeMT: TFDMemTable;
    ProductSizeCB: TComboBox;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    OAAPIKeyEdit: TEdit;
    MaskImage: TImage;
    APIXRayTabItem: TTabItem;
    XrayMemo: TMemo;
    Label3: TLabel;
    Layout4: TLayout;
    Image1: TImage;
    Image2: TImage;
    Layout5: TLayout;
    Image3: TImage;
    Image4: TImage;
    ImageCountTB: TTrackBar;
    NumLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ScreenshotButtonClick(Sender: TObject);
    procedure GenerateButtonClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure APIKeyButtonClick(Sender: TObject);
    procedure ListView1ItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure OpenButtonClick(Sender: TObject);
    procedure ScaleTBChange(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure ImageCountTBChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function MemoryStreamToBase64(const MemoryStream: TMemoryStream): string;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  System.Hash, System.NetEncoding, System.Net.Mime, System.JSON, System.Generics.Collections,
  System.IOUtils;

function TMainForm.MemoryStreamToBase64(const MemoryStream: TMemoryStream): string;
var
  OutputStringStream: TStringStream;
  Base64Encoder: TBase64Encoding;
  MimeType: string;
begin
  MemoryStream.Position := 0;
  OutputStringStream := TStringStream.Create('', TEncoding.ASCII);
  try
    Base64Encoder := TBase64Encoding.Create;
    try
      Base64Encoder.Encode(MemoryStream, OutputStringStream);
      MimeType := 'image/png';
      Result := 'data:' + MimeType + ';base64,' + OutputStringStream.DataString;
    finally
      Base64Encoder.Free;
    end;
  finally
    OutputStringStream.Free;
  end;
end;

procedure TMainForm.OpenButtonClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    ImageEdit.Text := OpenDialog.FileName;
    SourceImage.Bitmap.LoadFromFile(ImageEdit.Text);
    PaintLayout.Width := SourceImage.Bitmap.Width;
    PaintLayout.Height := SourceImage.Bitmap.Height;
    WidthEdit.Text := SourceImage.Bitmap.Width.ToString;
    HeightEdit.Text := SourceImage.Bitmap.Height.ToString;
  end;
end;

procedure TMainForm.APIKeyButtonClick(Sender: TObject);
begin
  OAAPIKeyEdit.Visible := not OAAPIKeyEdit.Visible;
  APIKeyEdit.Visible := not APIKeyEdit.Visible;
end;

function EncodeJSONStr(const S: String): String;
var
  JSONValue: TJSONString;
begin
  JSONValue := TJSONString.Create(S);
  try
    Result := JSONValue.ToJSON;
  finally
    JSONValue.Free;
  end;
end;

procedure TMainForm.GenerateButtonClick(Sender: TObject);
begin
  if APIKeyEdit.Text='' then
  begin
    ShowMessage('Enter a Replicate.com API key.');
    Exit;
  end;

  ProgressBar.Value := 0;
  ProgressBar.Visible := True;
  GenerateButton.Enabled := False;

  Application.ProcessMessages;

  var LSourceStream := TMemoryStream.Create;
  if ImageEdit.Text.Substring(0,4)<>'http' then
  begin
    if ImageEdit.Text<>'' then
    begin
      LSourceStream.LoadFromFile(ImageEdit.Text);
    end
    else
      SourceImage.Bitmap.SaveToStream(LSourceStream);
  end;

  RestRequest1.Params[0].Value := 'Token ' + APIKeyEdit.Text;
  RestRequest1.Params[1].Value := TemplateMemo.Lines.Text.Replace('%prompt%',PromptMemo.Lines.Text)
  .Replace('%base64source%','"'+MemoryStreamToBase64(LSourceStream)+'"')
  .Replace('%negative_prompt%',NegativePromptEdit.Text).Replace(#13#10,'')
  .Replace('%product_size%',ProductSizeCB.Selected.Text)
  .Replace('%width%',WidthEdit.Text)
  .Replace('%height%',HeightEdit.Text)
  .Replace('%openai%',OAAPIKeyEdit.Text)
  .Replace('%imagecount%',ImageCountTB.Value.ToString)
  .Replace('%scale%',ScaleTB.Value.ToString);

  XrayMemo.Lines.Append('POST Request');
  XrayMemo.Lines.Append('URL:');
  XrayMemo.Lines.Append(RestClient1.BaseURL+#13#10);
  XrayMemo.Lines.Append('Payload:');
  XrayMemo.Lines.Append(TemplateMemo.Lines.Text.Replace('%prompt%',PromptMemo.Lines.Text)
  .Replace('%base64source%','"'+'...'+'"')
  .Replace('%negative_prompt%',NegativePromptEdit.Text).Replace(#13#10,'')
  .Replace('%product_size%',ProductSizeCB.Selected.Text)
  .Replace('%width%',WidthEdit.Text)
  .Replace('%height%',HeightEdit.Text)
  .Replace('%openai%',OAAPIKeyEdit.Text)
  .Replace('%imagecount%',ImageCountTB.Value.ToString)
  .Replace('%scale%',ScaleTB.Value.ToString));
  XrayMemo.Lines.Append('');

  RESTRequest1.Execute;

  LSourceStream.Free;

  XrayMemo.Lines.Append('Response:');
  XrayMemo.Lines.Append(RESTResponse1.Content);
  XrayMemo.Lines.Append('');

  var F := FDMemTable1.FindField('status');
  if F<>nil then
  begin
    if F.AsWideString='starting' then
    begin
      RESTRequest2.Resource := FDMemTable1.FieldByName('id').AsWideString;

      Timer1.Enabled := True;
    end
    else
    begin
      ProgressBar.Visible := False;
      GenerateButton.Enabled := True;
      ShowMessage(F.AsWideString);
    end;
  end;
end;

procedure TMainForm.Image1Click(Sender: TObject);
begin
  if TImage(Sender).Bitmap.Width>0 then
    ImageViewer.Bitmap.Assign(TImage(Sender).Bitmap);
end;

procedure TMainForm.ImageCountTBChange(Sender: TObject);
begin
  NumLabel.Text := 'Image Count: ' + ImageCountTB.Value.ToString;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  var LDataFile := ExtractFilePath(ParamStr(0)) + 'ailb_database.fds';
  if TFile.Exists(LDataFile) then
    FileMemTable.LoadFromFile(LDataFile);

  WidthEdit.Text := SourceImage.Bitmap.Width.ToString;
  HeightEdit.Text := SourceImage.Bitmap.Height.ToString;

  ProductSizeCB.ItemIndex := 2;
end;

procedure TMainForm.ScaleTBChange(Sender: TObject);
begin
  ScaleLabel.Text := 'Scale: ' + ScaleTB.Value.ToString;
end;

procedure TMainForm.ScreenshotButtonClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    begin
      PreviewImage.Bitmap.SaveToFile(SaveDialog1.FileName);
    end;
end;

function ParseJSONStrArray(const JSONStr: String): TArray<String>;
var
  JSONArray: TJSONArray;
  I: Integer;
begin
  JSONArray := TJSONObject.ParseJSONValue(JSONStr) as TJSONArray;
  try
    SetLength(Result, JSONArray.Count);
    for I := 0 to JSONArray.Count - 1 do
      Result[I] := JSONArray.Items[I].Value;
  finally
    JSONArray.Free;
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  RestRequest2.Params[0].Value := 'Token ' + APIKeyEdit.Text;
  RESTRequest2.Execute;

  var F := FDMemTable2.FindField('status');
  if F<>nil then
  begin
    if F.AsWideString='succeeded' then
    begin
      Timer1.Enabled := False;
      XrayMemo.Lines.Append('GET Request');
      XrayMemo.Lines.Append('URL:');
      XrayMemo.Lines.Append(RestClient2.BaseURL+'/'+RESTRequest2.Resource+#13#10);

      XrayMemo.Lines.Append('Response');
      XrayMemo.Lines.Append(RESTResponse2.Content+#13#10);

      var OutputArray := ParseJSONStrArray(FDMemTable2.FieldByName('output').AsWideString);
      var LHash := THashMD5.GetHashString(OutputArray[1]);
      var LFilename := '';

      Image1.Bitmap.Clear(TAlphaColorRec.Null);
      Image2.Bitmap.Clear(TAlphaColorRec.Null);
      Image3.Bitmap.Clear(TAlphaColorRec.Null);
      Image4.Bitmap.Clear(TAlphaColorRec.Null);

      for var I := 1 to High(OutputArray) do
      begin
        var LImageURL := OutputArray[I];

        var LMS := TMemoryStream.Create;

        NetHTTPClient1.Get(LImageURL,LMS);

        if (I=1) then
        begin
          LFilename := ExtractFilePath(ParamStr(0)) + LHash + '.png';
          FileMemTable.AppendRecord([LFilename,PromptMemo.Lines.Text]);
          FileMemTable.SaveToFile(ExtractFilePath(ParamStr(0)) + 'ailb_database.fds');

          PreviewImage.Bitmap.LoadFromStream(LMS);
          ImageViewer.Bitmap.LoadFromStream(LMS);

          Image1.Bitmap.LoadFromStream(LMS);
        end
        else
        begin
          LFilename := ExtractFilePath(ParamStr(0)) + LHash + '_' + I.ToString + '.png';
          if I=2 then Image2.Bitmap.LoadFromStream(LMS);
          if I=3 then Image3.Bitmap.LoadFromStream(LMS);
          if I=4 then Image4.Bitmap.LoadFromStream(LMS);
        end;

        LMS.SaveToFile(LFilename);

        LMS.Free;
      end;

      var LMaskImageURL := OutputArray[0];
      var LMaskMS := TMemoryStream.Create;

      NetHTTPClient1.Get(LMaskImageURL,LMaskMS);

      var LMaskFilename := ExtractFilePath(ParamStr(0)) + LHash + '_mask.png';
      LMaskMS.SaveToFile(LMaskFilename);

      MaskImage.Bitmap.LoadFromStream(LMaskMS);

      LMaskMS.Free;

      var LOriginalFilename := ExtractFilePath(ParamStr(0)) + LHash + '_original.png';
      SourceImage.Bitmap.SaveToFile(LOriginalFileName);

      ProgressBar.Visible := False;
      GenerateButton.Enabled := True;

      TabControl.ActiveTab := ViewTabItem;
    end
    else
    if F.AsWideString='failed' then
    begin
      Timer1.Enabled := False;

      XrayMemo.Lines.Append('GET Request');
      XrayMemo.Lines.Append('URL:');
      XrayMemo.Lines.Append(RestClient2.BaseURL+'/'+RESTRequest2.Resource+#13#10);

      XrayMemo.Lines.Append('Response');
      XrayMemo.Lines.Append(RESTResponse2.Content+#13#10);

      ProgressBar.Visible := False;
      GenerateButton.Enabled := True;
      ShowMessage(FDMemTable2.FieldByName('error').AsWideString);
    end;
  end;
end;

procedure TMainForm.Timer2Timer(Sender: TObject);
begin
    if ProgressBar.Value=ProgressBar.Max then
      ProgressBar.Value := ProgressBar.Min
    else
      ProgressBar.Value := ProgressBar.Value+5;
end;

procedure TMainForm.ListView1ItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  Image1.Bitmap.Clear(TAlphaColorRec.Null);
  Image2.Bitmap.Clear(TAlphaColorRec.Null);
  Image3.Bitmap.Clear(TAlphaColorRec.Null);
  Image4.Bitmap.Clear(TAlphaColorRec.Null);

  if TFile.Exists(ImagePathEdit.Text) then
  begin
    ImageViewer.Bitmap.LoadFromFile(ImagePathEdit.Text);
    PreviewImage.Bitmap.LoadFromFile(ImagePathEdit.Text);
    Image1.Bitmap.Assign(ImageViewer.Bitmap);

    var LImage2 := ImagePathEdit.Text.Replace('.png','_2.png');
    if TFile.Exists(LImage2) then
    begin
      Image2.Bitmap.LoadFromFile(LImage2);
    end
    else
      Image2.Bitmap.Width := 0;

    var LImage3 := ImagePathEdit.Text.Replace('.png','_4.png');
    if TFile.Exists(LImage3) then
    begin
      Image3.Bitmap.LoadFromFile(LImage3);
    end
    else
      Image3.Bitmap.Width := 0;

    var LImage4 := ImagePathEdit.Text.Replace('.png','_3.png');
    if TFile.Exists(LImage4) then
    begin
      Image4.Bitmap.LoadFromFile(LImage4);
    end
    else
      Image4.Bitmap.Width := 0;
  end;

  var LMaskImage := ImagePathEdit.Text.Replace('.png','_mask.png');
  if TFile.Exists(LMaskImage) then
  begin
    MaskImage.Bitmap.LoadFromFile(LMaskImage);
  end;

  var LOriginalImage := ImagePathEdit.Text.Replace('.png','_original.png');
  if TFile.Exists(LOriginalImage) then
  begin
    SourceImage.Bitmap.LoadFromFile(LOriginalImage);
  end;



  PromptMemo.Lines.Text := FileMemTable.FieldByName('prompt').AsWideString;

  TabControl.ActiveTab := ViewTabItem;
end;

end.
