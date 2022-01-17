Logger = {
  Log = function(info, string)
      local formattedLog = string.format('%s\t[^2%s^7] %s', "[^2AOP LOG^7]", info, string)
      print(formattedLog)
  end,
  Info = function(info, string)
      local formattedLog = string.format('%s\t[^5%s^7] %s', "[^5AOP INFO^7]", info, string)
      print(formattedLog)
  end,
  Warn = function(info, string)
      local formattedLog = string.format('%s\t[^3%s^7] %s', "[^3AOP WARN^7]", info, string)
      print(formattedLog)
  end,
  Error = function(info, string)
      local formattedLog = string.format('%s\t[^9%s^7] %s', "[^9AOP ERROR^7]", info, string)
      print(formattedLog)
  end
}