RunHandled(
  function()
    if Stand:IsSolved() then
      Door:AssureOpened()
    end
    WaitForever()
  end,

  On(Event(Stand.Solved)),
    function()
      Door:Open()
    end
)