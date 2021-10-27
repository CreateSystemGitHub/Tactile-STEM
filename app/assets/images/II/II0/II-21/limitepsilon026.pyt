x=sp.Symbol('x')
sp.expr=sp.ln(1+x)
sp.expr.evalf(subs={x:0.01})
}