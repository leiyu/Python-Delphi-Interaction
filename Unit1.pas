unit Unit1;

{$I Definition.Inc}

interface

uses
  SysUtils, Classes,
{$IFDEF MSWINDOWS}
  Windows, Messages, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls,
{$ENDIF}
{$IFDEF LINUX}
  QForms, QDialogs, QStdCtrls, QControls, QExtCtrls,
{$ENDIF}
  PythonEngine, PythonGUIInputOutput;

//貌似在 Python4Delphi中，只能通过 Variant 来在 delphi和 Python 中传递数据
//应该有传递指针的办法
//但我先用变体解决一下
//因为 Variant 的性能太差，我不可能把数组全部转为变体
//我需要的是，把数组的首地址和个数传给Python
//这样Python就知道如何使用了
//释放这个数组内存，也需要在 delphi中完成
//还是像之前的 SetRawData 和 ReleaseData 过程做的事


type
    PArrDouble = ^ArrDouble;
    ArrDouble = array of double;

type
  TForm1 = class(TForm)
    PythonEngine1: TPythonEngine;
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    Splitter1: TSplitter;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    PythonDelphiVar1: TPythonDelphiVar;
    Button4: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    PythonGUIInputOutput1: TPythonGUIInputOutput;
    PythonDelphiVar2: TPythonDelphiVar;
    Memo2: TMemo;
    btn1: TButton;
    myDelphiVar: TPythonDelphiVar;
    btnTemp: TButton;
    btn2: TButton;
    btn3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure PythonDelphiVar1Change(Sender: TObject);
    procedure PythonDelphiVar1GetData(Sender: TObject; var Data: Variant);
    procedure PythonDelphiVar1SetData(Sender: TObject; Data: Variant);
    procedure PythonDelphiVar2ExtGetData(Sender: TObject;
      var Data: PPyObject);
    procedure PythonDelphiVar2ExtSetData(Sender: TObject; Data: PPyObject);
    procedure btn1Click(Sender: TObject);
    procedure btnTempClick(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure MyDelphiVar2ExtGetData(Sender: TObject; var Data: PPyObject);
    procedure MyDelphiVar2ExtSetData(Sender: TObject; Data: PPyObject);
    procedure btn3Click(Sender: TObject);
  private
    { D閏larations priv閑s }
    FMyPythonObject : PPyObject;
    FMyPyArray : PPyObject;

  public
    { D閏larations publiques }
    procedure DelphiArrayToNumPY();

  end;

var
  Form1: TForm1;
  FTestArr: PArrDouble;  //当作全局变量
  FArr: ArrDouble;

implementation
{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  PythonEngine1.ExecStrings( Memo1.Lines );
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  with OpenDialog1 do
    begin
      if Execute then
        Memo1.Lines.LoadFromFile( FileName );
    end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  with SaveDialog1 do
    begin
      if Execute then
        Memo1.Lines.SaveToFile( FileName );
    end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  ShowMessage( 'Value = ' + PythonDelphiVar1.ValueAsString );
end;

procedure TForm1.PythonDelphiVar1Change(Sender: TObject);
begin
  with Sender as TPythonDelphiVar do
    ShowMessage( 'Var test changed: ' + ValueAsString );
end;

procedure TForm1.PythonDelphiVar1GetData(Sender: TObject;
  var Data: Variant);
begin
  Data := Edit1.Text;
end;

procedure TForm1.PythonDelphiVar1SetData(Sender: TObject; Data: Variant);
begin
  Edit1.Text := Data;
end;

procedure TForm1.PythonDelphiVar2ExtGetData(Sender: TObject;
  var Data: PPyObject);
begin
  with GetPythonEngine do
    begin
      Data := FMyPythonObject;
      Py_XIncRef(Data); // This is very important
    end;
end;

procedure TForm1.PythonDelphiVar2ExtSetData(Sender: TObject;
  Data: PPyObject);
begin
  with GetPythonEngine do
    begin
      Py_XDecRef(FMyPythonObject); // This is very important
      FMyPythonObject := Data;
      Py_XIncRef(FMyPythonObject); // This is very important
    end;
end;

procedure TForm1.btn1Click(Sender: TObject);

begin

  DelphiArrayToNumPY();


  Memo2.Lines.Clear;


  Memo2.Lines.Append('FTestArr=' + IntToStr(Integer(FTestArr)));
  Memo2.Lines.Append('@FTestArr=' + IntToStr(Integer(@FTestArr)));
  Memo2.Lines.Append('Address of FTestArr=' + IntToStr(Integer(Addr(FTestArr))));

  Memo2.Lines.Append('inited FTestArr' + IntToStr(myDelphiVar.Value));


end;




procedure TForm1.DelphiArrayToNumPY;
begin

  new(FTestArr);
  SetLength(FTestArr^, 10);

  FTestArr^[0] := 1.0;
  FTestArr^[1] := 2.0;
  FTestArr^[2] := 3.0;
  FTestArr^[3] := 4.0;
  FTestArr^[4] := 5.0;
  FTestArr^[5] := 6.0;
  FTestArr^[6] := 7.0;
  FTestArr^[7] := 8.0;
  FTestArr^[8] := 9.0;
  FTestArr^[9] := 10.0;

  // 但无论是指针变量的值，还是指针的地址，都不对
  //delphi 动态数组的问题，需要取第0个元素的地址
  //myDelphiVar.Value := Integer(Addr(FTestArr));

  myDelphiVar.Value := Integer(@FTestArr^[0]);

    //ShowMessage('DelphiArrayToNumPY()');
end;

procedure TForm1.btnTempClick(Sender: TObject);
var
  tempPointer: Pointer;


begin



  ShowMessage(IntToStr(SizeOf(double)));

end;

procedure TForm1.btn2Click(Sender: TObject);
begin
  //换了这个方法也不好使，貌似内存地址传到 Python 后不一样了，是因为不在一个进程空间的原因吗？

  SetLength(FArr, 10);

  FArr[0] := 1.0;
  FArr[1] := 2.0;
  FArr[2] := 3.0;
  FArr[3] := 4.0;
  FArr[4] := 5.0;
  FArr[5] := 6.0;
  FArr[6] := 7.0;
  FArr[7] := 8.0;
  FArr[8] := 9.0;
  FArr[9] := 10.0;

  myDelphiVar.Value := Integer(@FArr[0]);

  Memo2.Lines.Clear;


  Memo2.Lines.Append('@FArr=' + IntToStr(Integer(@FArr)));
  Memo2.Lines.Append('@FArr[0]=' + IntToStr(Integer(@FArr[0])));

  Memo2.Lines.Append('passed FArr' + IntToStr(myDelphiVar.Value));

  Memo2.Lines.Append('size of FArr' + IntToStr(SizeOf(FArr)));


end;

procedure TForm1.MyDelphiVar2ExtGetData(Sender: TObject;
  var Data: PPyObject);
begin
 with GetPythonEngine do
    begin
      Data := FMyPyArray;
      Py_XIncRef(Data); // This is very important
    end;
end;

procedure TForm1.MyDelphiVar2ExtSetData(Sender: TObject; Data: PPyObject);
begin
    with GetPythonEngine do
    begin
      Py_XDecRef(FMyPyArray); // This is very important
      FMyPyArray := Data;
      Py_XIncRef(FMyPyArray); // This is very important
    end;
end;

procedure TForm1.btn3Click(Sender: TObject);
var
  strTemp : String;
  p: Pointer;
  i: integer;
begin
  Memo2.Lines.Add('Delphi Var:' + IntToStr(Integer(myDelphiVar.Value)));

  p := Pointer(Integer(myDelphiVar.Value));
  strTemp := '';
  for i := 0 to 9 do
  begin
    strTemp := strTemp + FloatToStr(ArrDouble(p)[i]) + ',';

  end;

  Memo2.Lines.Append('python result array:' + strTemp);

end;

end.
