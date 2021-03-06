#Model of parasitic infection in mice with random intercept 
#based on population

model {
  
  #Hyperpriors
  alpha.mean ~ dunif(-100,100)
  alpha.sd ~ dunif(0,100)
  alpha.prec <- 1 / (alpha.sd*alpha.sd)
  
  #Priors
  beta.latrine ~ dnorm(0,0.01)
  
  #Generate random effect
  
  for (i in 1:npop){
    alpha[i] ~ dnorm(alpha.mean,alpha.prec)
  }
  
  # Likelihood
  #Note double indexing of population
  for(i in 1:nobs){
    #Model expected p as a function of covariates (logit transform)
    logit(p[i]) <- alpha[pop[i]] + beta.latrine*latrine[i] 
    #Model actual observed infection status
    infect[i] ~ dbern(p[i])
    #Absolute residual
    res[i] <- abs(infect[i] - p[i])
    #Generate new dataset
    infect.new[i] ~ dbern(p[i])
    res.new[i] <- abs(infect.new[i] - p[i])
  }
  
  #Derived parameters for posterior predictive check
  fit <- sum(res[])
  fit.new <- sum(res.new[])
  
}