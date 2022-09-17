unit Ticker;

interface

uses IniFile;

var
  market: string;

type
  TTicker = class
  public
    function GetMarketTicker: array of decimal;
  end;

implementation

function Ticker.TTicker.GetMarketTicker: array of decimal;
begin
  market := IniFile.TIniFile.Create('Parameters.ini').ReadString('MainParameters', 'market', '');
  var request := System.Net.WebRequest.CreateHttp('https://graviex.net/webapi/v3/tickers/' + market + '.json');
  request.Method := 'GET';
  request.Timeout := 100000;
  var xml := Newtonsoft.Json.JsonConvert.DeserializeXmlNode(System.IO.StreamReader.Create(request.GetResponse.GetResponseStream).ReadToEnd, 'CoinTicker');  
  SetLength(Result, 3);
  Result[0] := decimal.Parse(xml.GetElementsByTagName('sell')[0].InnerText);
  Result[1] := decimal.Parse(xml.GetElementsByTagName('buy')[0].InnerText);
  Result[2] := decimal.Parse(xml.GetElementsByTagName('last')[0].InnerText);
end;
end.