unit Loger;

interface

type
  TLoger = class
  public
    function Write(data: string): string;
  end;

implementation

function Loger.TLoger.Write(data: string): string;
begin
  WriteAllText('botlog.log', DateTime.Now.ToString + ': ' + data);
end;
end.