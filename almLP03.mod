
set nodes ordered;
param pred{nodes};
param prob{nodes};


set assets;
param price1{assets};
param mu{assets};
param sigma{assets};
param c;
param dt;


param stage{n in nodes} := if n = 1 then 1 else stage[pred[n]] + 1;
param T   := stage[last(nodes)];
set stages = 1..T;
param uprob{n in nodes} := if n = 1 then 1.0 else uprob[pred[n]]*prob[n];



param e {n in nodes, a in assets} :=  Normal01();

param phi {n in nodes, a in assets} := 
if a = 'stock' then sqrt(1 - c*c) * e[n, 'stock'] + c*e[n,'bond']
else e[n,'bond'];


param price {n in nodes, a in assets} := 
if n = first(nodes) then price1[a]
else price[pred[n], a] *( 1 + mu[a]*dt + sigma[a]*sqrt(dt)*phi[n,a]); 




# Decision variables 
var x{nodes, assets} >= 0;



# Objective Function
maximize wealth : sum{a in assets, n in nodes: stage[n] = T} 
                  (uprob[n]*price[n,a]*x[n,a]);



s.t. selfFinancing{n in nodes: stage[n] <> 1}:
  sum{a in assets} price[n,a]*x[n,a] = sum{a in assets} price[n,a]*x[pred[n],a];


s.t. budget:
  sum{a in assets} price[first(nodes),a]*x[first(nodes),a] <= 100;
