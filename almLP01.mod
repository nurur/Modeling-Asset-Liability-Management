# Model File 
# Deterministic ALM model 
# 10 assets (i) and 4 time stages (t) 
# Transaction cost (g) is 2.5% of the value of each trade 
# Initial income (F) is 150,000 (in $US)


#PARAMETERS: SCALARS
param NA       := 10;                     # Number of assets
param NT       := 4;                      # Number of time stages
param tbuy     := 1.025;                  # Transaction cost to buy   (1+g)
param tsell    := 0.975;                  # Transeaction cost to sell (1-g)
param risklevel:= 0.200;                  # Risk level for downside risk (20 %)


#SETS
set as    := 1..NA;                       # Set of assets     = i = 10
set ts    := 1..NT;                       # Set of time stages= t = 4


#PARAMETERS : VECTORS 
param x{ts, as};                          # Asset price
param H0{as}>=0;                          # Initial Holding of the portfolio
param L{ts} >=0;                          # Liability in stage t
param F{ts} >=0;                          # Funding in stage t
param A{ts} >=0;                          # Target at the end time stage t


#DECISION VARIABLES
var H{t in ts, a in as} >=0;              # Amount to hold
var B{t in ts, a in as} >=0;              # Amount to buy
var S{t in ts, a in as} >=0;              # Amount to sell



#OBJECTIVE FUCNTION 
maximize wealth : sum{a in as} (x[card(ts),a] * H[card(ts),a]);



#CONSTRAINTS
# Asset Holding 
s.t. assetHolding1{a in as}:
      H[1,a] = H0[a] + B[1,a] - S[1,a];

s.t. assetHolding2{t in 2..NT, a in as}:
      H[t,a] = H[t-1,a] + B[t,a] - S[t,a];


# Fund Balance 
s.t. fundbalance{t in ts}:
     sum{a in as} B[t,a] * x[t,a]*tbuy - sum{a in as} S[t,a] * x[t,a]*tsell 
     = F[t] - L[t];


# Downside Risk 
s.t. downsideRisk{t in 2..NT}: 
     A[t] - sum{a in as} (x[t,a]*H[t,a]) <= risklevel * A[t];




#var marketvalue{ts} >= 0;
#maximize wealth : marketvalue[ card(ts) ];

# Accumulation of Wealth 
#s.t. assetmarketvalue1:
#      marketvalue[1] = sum{a in as} initialholdings[a] * x[1,a];

#s.t. assetmarketvalue2{t in 2..NT}:
#     marketvalue[t] = sum{a in as} H[t,a] * x[t,a];


