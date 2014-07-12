# almLP02
# Model File 
# Stochastic ALM model 
# 4 assets (i) and 2 time stages (t) 
# Transaction cost (g) is 2.5% of the value of each trade 
# Initial income (F) is 150,000 (in $US)


#PARAMETERS: SCALARS
param NA       := 4;                      # Number of assets
param NT       := 2;                      # Number of time stages
param NS       := 8;                      # Number of Scenarios
 
param tbuy     := 1.025;                  # Transaction cost to buy   (1+g)
param tsell    := 0.975;                  # Transeaction cost to sell (1-g)
param risklevel:= 0.200;                  # Risk level for downside risk (20 %)



# SETS
set as     := 1..NA;                      # Set of assets
set ts     := 1..NT;                      # Set of time stages 


# Stochastic Part 
# Scenarios and Stages 
set scen      := 1..NS;                   # Set of scenarios
#Probabilities 
param p{scen} := 1/NS;



# RANDOM PARAMETERS : 
param x{ts, as, scen};



# NON-RANDOM PARAMETERS : 
param L{ts} >= 0;
param F{ts} >= 0;
param A{ts};
param H0{as} := 0;


# VARIABLES (amountHold, amountBuy, amountSell)
# For example, second-stage variables should be marked with suffix stage 2
#suffix stage LOCAL;                       
#var H{t in ts, a in as, s in scen} >=0, suffix stage t;
#var B{t in ts, a in as, s in scen} >=0, suffix stage t;
#var S{t in ts, a in as, s in scen} >=0, suffix stage t;
#var marketvalue{t in ts, s in scen}>=0, suffix stage t;


var H{t in ts, a in as, s in scen} >=0;
var B{t in ts, a in as, s in scen} >=0;
var S{t in ts, a in as, s in scen} >=0;
var marketvalue{t in ts, s in scen}>=0;



#OBJECTIVE
maximize wealth : sum{s in scen} ( p[s]*marketvalue[card(ts), s] );



#CONSTRAINTS
subject to assetmarketvalue1{s in scen}:
      marketvalue[1,s] = sum{a in as} H0[a] * x[1,a,s];

assetmarketvalue2{t in 2..NT, s in scen}:
marketvalue[t,s] = sum{a in as} H[t,a,s] * x[t,a,s];


# Asset Holding 
stockbalance1{a in as, s in scen}:
      H[1,a,s] = H0[a] + B[1,a,s] - S[1,a,s];

stockbalance2{t in 2..NT, a in as, s in scen}:
      H[t,a,s] = H[t-1,a,s] + B[t,a,s] - S[t,a,s];


# Fund Balance 
s.t. fundbalance{t in ts, s in  scen}:
     sum{a in as} B[t,a,s]*x[t,a,s]*tbuy - sum{a in as} S[t,a,s]*x[t,a,s]*tsell 
     = F[t] - L[t];


# Downside Risk 
s.t. downsideRisk{t in 2..NT, s in scen}: 
     A[t] - marketvalue[t,s] <= risklevel * A[t];



