#############################################
##Bayesian Analysis of More Complex Models
#############################################

##These models incorporate latent (unobserved) parameters
##Very useful for explicitly modeling both biological and observation processes

#Example 1: Occupancy Modeling

#Simulate data

#Number of sites
n = 100
nobs = 5
forest = rnorm(n,0,1)

#True values
alpha = 2
b.forest = 3.1
p = 0.35

z=vector(length=n)
#Biological process
for (i in 1:n){
  linpred <- alpha + b.forest*forest[i]
  psi <- exp(linpred)/(1+exp(linpred))
  z[i] <- rbinom(1,1,psi)  
}

obs=vector(length=n)
#Observation process
for (i in 1:n){
  obs[i] <- z[i]*rbinom(1,nobs,p)
}

#######################################

#Run Analysis

data = list(n=n,obs=obs,nobs=nobs,forest=forest)

modFile = "models/model_occ.R"

params = c('alpha','b.forest','prob.occ','p')

#Initial values

#Need to initialize z - init to 'naive' occupancy
zinit = rep(0,n)
zinit[obs!=0] = 1

inits = function(){list(z=zinit)}

library(jagsUI)
out <- jags(data=data,inits=inits,parameters.to.save=params,model.file=modFile,
                  n.adapt=100,n.chains=3,n.iter=2000,n.burnin=1000,n.thin=2)

out

traceplot(out)
densityplot(out)

#Simple logistic regression in R
#Remember zinit is naive occupancy

freq.out <- glm(zinit ~ forest,family=binomial)

summary(freq.out)

###################################################

#Example 2: N-mixture model
#Model abundance without marked animals

#Simulate data

#Number of sites / true parameter values

nsites = 100
forest = rnorm(nsites,0,1)
alpha = 2
b.forest = -0.8

#Ecological process

N = vector(length=nsites)
#Generate abundance (Poisson) for each site based on forest variable
for (i in 1:nsites){
  lambda = exp(alpha+b.forest*forest[i])
  N[i] = rpois(1,lambda)
}

#Observation process
#How many sampling occasions?
nobs = 5
#Constant probability of detection
p = 0.45
#How many animals were observed at each site on each occasion?
obs = matrix(data=NA,nrow=n,ncol=nobs)
for (i in 1:nsites){
  for (j in 1:nobs){
    obs[i,j] <- rbinom(1,N[i],p)
}}

#Run analysis

data = list(nsites=nsites,nobs=nobs,obs=obs,forest=forest)

params = c('alpha','b.forest','p','N')

#Need to initialize latent parameter N - using max # of animals observed at that site
Nit <- apply(obs,1,max)
inits = function(){list(N=Nit)}

modFile = 'models/model_Nmix.R'

library(jagsUI)
out2 = jags(data=data,inits=inits,parameters.to.save=params,model.file=modFile,
                  n.adapt=100,n.chains=3,n.iter=3000,n.burnin=1500,n.thin=2)

out2

#Check correspondance of true and estimated N

plot(N,out2$mean$N[1:100],xlab="Actual N",ylab="Estimated N",
     main="N Comparison")
abline(1,1)

#Check correlation
cor(N,out2$mean$N[1:100])
