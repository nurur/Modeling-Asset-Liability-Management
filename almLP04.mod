# almLP04
# Model File 
# Stochastic ALM model 
# 6 assets and 4 time stages  
# Transaction cost (g) is 2.5% of the value of each trade 
# Initial income is 500,000 (in $US)



# Fixed Parameters of the portfolio   
param g        := 0.025;          # Transaction cost to buy (1+g) or sell (1-g)
param risklevel:= 0.100;          # Risk level for downside risk (10 %)



# Nodes
set nodes ordered;                # Nodes is an ordered set 
param pred{nodes};                # Predessesor node of branch 
param prob{nodes};                # Conditional probability of each leaf node  



# Stages  
param stage{n in nodes} := if n = 1 then 1 else stage[pred[n]] + 1;
param T   := stage[last(nodes)];
set stages = 1..T;

# Unconditional Probability of each node 
param uprob{n in nodes} := if n = 1 then 1.0 else uprob[pred[n]]*prob[n];



# Random Parameters (Price) ###################################
set as;   
param x1{as};
param mu{as};
param sigma{as};

param e {n in nodes, a in as} :=  0.5*Normal01();

param x{n in nodes, a in as} := if n = first(nodes) then x1[a] 
                                else x[pred[n],a] * (1 + mu[a] + sigma[a]*e[n,a]);



# Non-random parameters 
param L{nodes} >= 0;
param F{nodes} >= 0;
param A{nodes} >= 0;
param H0{as}   := 0;



# Decision Variables (amountToHold H, amountToBuy B, amountToSell S)
var H{n in nodes, a in as} >=0 ;
var B{n in nodes, a in as} >=0 ;
var S{n in nodes, a in as} >=0 ;



# Second Order Stochastic Dominance  
set benchMark = 1..10;            # Number of benchmark realization 
param mInd{benchMark};            # Market index for Sec. Stochastic dominance 
param pb{benchMark};              #
var s{nodes, benchMark} >= 0;     # Shortfall var for sec-ord stochastic dominance
var y{benchMark};                 #




# Objective Function 
# Sum over terminal nodes
maximize wealth : sum{a in as, n in nodes: stage[n]=T}  (uprob[n]*x[n,a]*H[n,a]);



# Constraints
# Asset Holding 
stockbalance1{a in as}:
      H[1,a] = H0[a] + B[1,a] - S[1,a];

stockbalance2{i in 2..T, a in as, n in nodes: stage[n]=i}:  
      H[n,a] = H[pred[n],a] + B[n,a] - S[n,a];


# Fund Balance 
s.t. fundbalance{i in stages, n in nodes: stage[n]=i}:
     sum{a in as} B[n,a]*x[n,a]*(1+g) - sum{a in as} S[n,a]*x[n,a]*(1-g) 
     = F[i] - L[i];



# Downside Risk 
s.t. downsideRisk{i in 2..T, n in nodes: stage[n]=i}: 
     A[i] - sum{a in as} (H[n,a]*x[n,a]) <= risklevel * A[i];



# Second-order Stochastic Dominance 
# At a given stage and 
# For a given node compare the Porfolio Return with Market Return 
   
s.t. ssd1{i in 2..T, k in benchMark, n in nodes: stage[n]=i}: 
     sum{a in as} (x[n,a]*H[pred[n],a]) + s[n,k] >= mInd[k];

s.t. ssd2{i in 2..T, k in benchMark}: 
     sum{n in nodes: stage[n]=i} (uprob[n]*s[n,k]) <= y[k]; 

s.t. ssd3{k in benchMark}: 
     y[k] >= sum{l in benchMark} ( pb[l] * (mInd[k] - mInd[l]) ); 

s.t. ssd4{k in benchMark}: y[k] >= 0; 




