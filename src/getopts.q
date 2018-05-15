/////////////
// PRIVATE //
/////////////

///
// Adds an expected command line argument with a specified default value and help message
// @param arg symbol Argument name
// @param val any Default value for argument
// @param help string Help message to output in usage details
// @param required boolean Flag to indicate if argument is required
.getopts.priv.addArg:{[arg;val;help;required]
  upsert[`.getopts.priv.arguments;(arg;enlist val;help;required)];
  }

///
// Clears an expected command line argument
// @param arg symbol Argument name
.getopts.priv.clear:{[pArg]
  delete from`.getopts.priv.arguments where arg=pArg;
  }

///
// Resets all command line arguments
.getopts.priv.reset:{[]
  .getopts.priv.arguments:1!flip`arg`val`help`required!"s**b"$\:();
  upsert[`.getopts.priv.arguments;(`help;enlist"";"show this message and exit";0b)];
  }

///
// Format usage line
// @param arg symbol Argument name
// @param required boolean Flag to indicate if argument is required
.getopts.priv.formatUsage:{[arg;required]
  arg:" "sv'flip("-",/:arg;upper arg:string arg except`help);
  " "sv$[required;arg;"[",'arg,'"]"]}

///
// Format arguments
// @param args symbolList List of argument names
.getopts.priv.formatArgs:{[args]
  args:-2_"\n"sv" ",/:"\n"vs .Q.s(`$"-",/:string args)!`$.getopts.priv.arguments[;`help]'[args];
  ssr[args;"| ";"\t"]}

///
// Output usage message to stdout
.getopts.priv.showUsage:{[]
  output:"\nUsage: q ",(string last` vs hsym .z.f)," [-help] ";
  -1 output," "sv .getopts.priv.formatUsage .'flip (value;key)@\:desc d:exec arg by required from .getopts.priv.arguments;

  if[count v:d 1b;
    -1"\nRequired arguments:";
    -1 .getopts.priv.formatArgs v];

  if[count v:d 0b;
    -1"\nOptional arguments:";
    -1 .getopts.priv.formatArgs v];
  }

///
// Parses command line arguments
.getopts.priv.parseArgs:{[]
  if[`help in k:key cmdline:.Q.opt .z.x;
    .getopts.priv.showUsage[];
    exit 0];

  missingArgs:not all(exec arg from .getopts.priv.arguments where required)in key cmdline;
  additionalArgs:count key[cmdline]except exec arg from .getopts.priv.arguments;

  if[missingArgs|additionalArgs;
    .getopts.priv.showUsage[];
    exit 1];

  res:.Q.def[exec arg!first@'val from .getopts.priv.arguments;cmdline]_`help;
  res}

////////////
// PUBLIC //
////////////

///
// Adds a required argument
// @param arg symbol Argument name
// @param val any Default value for argument
// @param help string Help message to output in usage details
.getopts.addArg:{[arg;val;help]
  .getopts.priv.addArg[arg;val;help;1b];
  }

///
// Adds an optional argument
// @param arg symbol Argument name
// @param val any Default value for argument
// @param help string Help message to output in usage details
.getopts.addOpt:{[arg;val;help]
  .getopts.priv.addArg[arg;val;help;0b];
  }

///
// Clears an argument
// @param arg symbol Argument name
.getopts.clear:{[arg]
  .getopts.priv.clear[arg];
  }

///
// Resets all command line arguments
.getopts.reset:{[]
  .getopts.priv.reset[];
  }

///
// Parses command line arguments
.getopts.parseArgs:{[]
  res:.getopts.priv.parseArgs[];
  res}

//////////
// INIT //
//////////

.getopts.reset[]
