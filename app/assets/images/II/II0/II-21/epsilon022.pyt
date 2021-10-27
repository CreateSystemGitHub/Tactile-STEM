x=sp.Symbol('x')
sp.expr=sp.sin(x)/x
sp.expr.evalf(subs={x:0.01})
}