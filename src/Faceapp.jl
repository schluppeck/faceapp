module Faceapp

using Genie, Logging, LoggingExtras

function main()
  Base.eval(Main, :(const UserApp = Faceapp))

  Genie.genie(; context = @__MODULE__)

  Base.eval(Main, :(const Genie = Faceapp.Genie))
  Base.eval(Main, :(using Genie))
end

end