#####################################################################################
#Copyright (C) <2012>
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of
#this software and associated documentation files (the "Software"), to deal in the
#Software without restriction, including without limitation the rights to use, copy,
#modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
#and to permit persons to whom the Software is furnished to do so, subject to
#the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies
#or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# This file is a component of the MaAsLin (Multivariate Associations Using Linear Models), 
# authored by the Huttenhower lab at the Harvard School of Public Health
# (contact Timothy Tickle, ttickle@hsph.harvard.edu).
#####################################################################################

inlinedocs <- function(
##author<< Curtis Huttenhower <chuttenh@hsph.harvard.edu> and Timothy Tickle <ttickle@hsph.harvard.edu>
##description<< Holds MaAsLin related plotting
) { return( pArgs ) }

funcPDF <- function(
### Function to plot raw data with linear model information.
### Continuous and integer variables are plotted with a line of best fit.
### Other data is plotted as boxplots.
frmeTmp,
lsCur,
### Linear model information
curPValue,
### Pvalue to display
curQValue,
### Qvalue to display
strFilePDF,
### PDF file to create or to which to append
strBaseOut,
### Project directory to place pdf in
strName,
### Name of taxon
funcUnTransform=NULL,
### If a transform is used the appropriate of that transfor must be used on the residuals in the partial residual plots
fDoResidualPlot = TRUE,
### Plot the residual plots
fInvert = FALSE,
### Invert the figure so the background is black
liNaIndices = c()
### Indices of NA data that was imputed
){
  if( is.na( strFilePDF ) )
  {
    strFilePDF <- sprintf( "%s-%s.pdf", strBaseOut, strName )
    pdf( strFilePDF, width = 11, useDingbats=FALSE )
  }
  
  #Invert plots
  adColorMin <- c(1, 0, 0)
  adColorMax <- c(0, 1, 0)
  adColorMed <- c(0, 0, 0)
  if( fInvert )
  {
    par( bg = "black", fg = "white", col.axis = "white", col.lab = "white", col.main = "white", col.sub = "white" )
    adColorMin <- c(1, 1, 0)
    adColorMax <- c(0, 1, 1)
    adColorMed <- c(1, 1, 1)
  }

  #Create linear model title data string
  strTitle <- sprintf( "%s (%.3g sd %.3g, p=%.3g, q=%.3g)", lsCur$orig, lsCur$value, lsCur$std, curPValue, curQValue )
  adMar <- c(5, 4, 4, 2) + 0.1
  dLine <- NA
  strTaxon <- lsCur$taxon
  if( nchar( strTaxon ) > 80 )
  {
    dCEX <- 0.75
    iLen <- nchar( strTaxon )
    if( iLen > 120 )
    {
      dLine <- 2.5
      i <- round( iLen / 2 )
      strTaxon <- paste( substring( strTaxon, 0, i ), substring( strTaxon, i + 1 ), sep = "\n" )
      adMar[2] <- adMar[2] + 1
    }
  } else { dCEX = 1 }

  #Plot 1x2 graphs per page
  if(fDoResidualPlot){par(mfrow=c(1,2))}

  # Plot factor data as boxplot if is descrete data
  # Otherwise plot as a line
  adCur <- lsCur$metadata
  adY <- lsCur$data

  # Remove NAs from data visualization if set to do so (if liNaIndices is not empty)
  if(lsCur$name %in% names(liNaIndices)&&(length(liNaIndices[[lsCur$name]])>0))
  {
    adY <- adY[-1*liNaIndices[[lsCur$name]]]
    adCur = adCur[-1*liNaIndices[[lsCur$name]]]
    if(class(adCur)=="factor")
    {
      adCur = factor(adCur)
    }
  }

  # Set the factor levels to include NA if they still exist
  # This is so if something is not imputed, then if there are NAs they will be plotted (to show no imputing)
  if( class( lsCur$metadata ) == "factor" )
  {
    sCurLevels = levels(adCur)
    adCur = (as.character(adCur))
    aiCurNAs = which(is.na(adCur))
    if(length(aiCurNAs) > 0)
    {
      adCur[aiCurNAs]="NA"
      sCurLevels = c(sCurLevels,"NA")
    }
    adCur = factor(adCur, levels = sCurLevels)
  }

  if( class( lsCur$metadata ) == "factor" )
  {
    astrNames <- c()
    astrColors <- c()
    dMed <- median( adY[adCur == levels( adCur )[1]], na.rm = TRUE )
    adIQR <- quantile( adY, probs = c(0.25, 0.75), na.rm = TRUE )
    dIQR <- adIQR[2] - adIQR[1]
    if( dIQR <= 0 )
    {
      dIQR <- sd( adY, na.rm = TRUE )
    }
    dIQR <- dIQR / 2

    #Print boxplots/strip charts of raw data. Add model data to it.
    for( strLevel in levels( adCur ) )
    {
      c_iLen <- 32
      strLength <- strLevel
      if( nchar( strLength ) > c_iLen )
      {
        iTmp <- ( c_iLen / 2 ) - 2
        strLength <- paste( substr( strLength, 1, iTmp ), substring( strLength, nchar( strLength ) - iTmp ), sep = "..." )
      }
      astrNames <- c(astrNames, sprintf( "%s (%d)", strLength, sum( adCur == strLevel, na.rm = TRUE ) ))
      astrColors <- c(astrColors, sprintf( "%sAA", funcColor( ( median( adY[adCur == strLevel], na.rm = TRUE ) - dMed ) /
        dIQR, dMax = 3, dMin = -3, adMax = adColorMin, adMin = adColorMax, adMed = adColorMed ) ))
    }
    #Controls boxplot labels
    #(When there are many factor levels some are skipped and not plotted
    #So this must be reduced)
    dBoxPlotLabelCex = dCEX
    if(length(astrNames)>8)
    {
      dBoxPlotLabelCex = dBoxPlotLabelCex * 1.5/(length(astrNames)/8)
    }
    par(cex.axis = dBoxPlotLabelCex)
    boxplot( adY ~ adCur, notch = TRUE, names = astrNames, mar = adMar, col = astrColors,
      main = strTitle, cex.main = 48/nchar(strTitle), xlab = lsCur$name, ylab = NA, cex.lab = dCEX, outpch = 4, outcex = 0.5 )
    par(cex.axis = dCEX)
    stripchart( adY ~ adCur, add = TRUE, col = astrColors, method = "jitter", vertical = TRUE, pch = 20 )
    title( ylab = strTaxon, cex.lab = dCEX, line = dLine )
  } else {
    #Plot continuous data
    plot( adCur, adY, mar = adMar, main = strTitle, xlab = lsCur$name, pch = 20,
      col = sprintf( "%s99", funcGetColor( ) ), ylab = NA, xaxt = "s" )
    title( ylab = strTaxon, cex.lab = dCEX )
    lmod <- lm( adY ~ adCur )
    dColor <- lmod$coefficients[2] * mean( adCur, na.rm = TRUE ) / mean( adY, na.rm = TRUE )
    strColor <- sprintf( "%sDD", funcColor( dColor, adMax = adColorMin, adMin = adColorMax, adMed = adColorMed ) )
    abline( reg = lmod, col = strColor, lwd = 3 )
  }
  ### Plot the residual plot
  if(fDoResidualPlot){funcResidualPlot(lsCur=lsCur, frmeTmp=frmeTmp, adColorMin=adColorMin, adColorMax=adColorMax, adColorMed=adColorMed, adMar, funcUnTransform=funcUnTransform, liNaIndices)}
  return(strFilePDF)
  ### File to which the pdf was written
}

### Plot 1
# axis 1 gene expression (one bug)
# axis 2 PC1 (bugs and metadata)(MFA)
# over plot real data vs the residuals (real data verses the prediction)
# remove all but 1 bug + metadata
### Plot 2
#residuals (y) PCL1 (1 bug + metadata)
#Plot 3
### Can plot the residuals against all the variables in a grid/lattic
funcGetFactorBoxColors = function(adCur,adY,adColorMin,adColorMax,adColorMed)
{
  astrColors = c()

  if( class( adCur ) == "factor" )
  {
    if( "NA" %in% levels( adCur ) )
    {
      afNA = adCur == "NA"
      adY = adY[!afNA]
      adCur = adCur[!afNA]
      adCur = factor( adCur, levels = setdiff( levels( adCur ), "NA" ) )
    }
    dMed = median( adY[adCur == levels( adCur )[1]], na.rm = TRUE )
    adIQR = quantile( adY, probs = c(0.25, 0.75), na.rm = TRUE )
    dIQR = adIQR[2] - adIQR[1]
    if( dIQR <= 0 )
    {
      dIQR <- sd( adY, na.rm = TRUE )
    }
    dIQR <- dIQR / 2

    for( strLevel in levels( adCur ) )
    {
      astrColors <- c(astrColors, sprintf( "%sAA", funcColor( ( median( adY[adCur == strLevel], na.rm = TRUE ) - dMed ) /
        dIQR, dMax = 3, dMin = -3, adMax = adColorMin, adMin = adColorMax, adMed = adColorMed ) ))
    }
  }
  return(astrColors)
}

funcResidualPlotHelper <- function(
frmTmp,
### The dataframe to plot from
sResponseFeature,
lsFullModelCovariateNames,
### All covariates in lm (Column Names)
lsCovariateToControlForNames,
### Y Axis: All the covariate which will be plotted together respectively * their beta with the residuals of the full model added. (These should dummied names for factor data; not column names).
sCovariateOfInterest,
### X Axis: raw data of the covariate of interest. (Column Name)
adColorMin,
### Min color in color range for markers
adColorMax,
### Max color in color range for markers
adColorMed,
### Medium color in color range for markers
adMar,
### Standardized margins
funcUnTransform = NULL,
### If a transform is used the opposite of that transfor must be used on the residuals in the partial residual plots
liNaIndices = c()
### Indices of NA data that was imputed
){
  # Get model matrix (raw data)
  adCur = frmTmp[[sResponseFeature]]

  # Make a formula to calculate the new model to get the full model residuals
  strFormula = paste("adCur",paste(sprintf( "`%s`", lsFullModelCovariateNames ),sep="", collapse="+"),sep="~")

  # Calculate lm
  lmod = (lm(as.formula(strFormula),frmTmp))

  # Get all coefficient data in the new model
  dfdCoefs = coefficients(lmod)

  # Get all coefficient names in the new model
  asAllCoefNames = names(dfdCoefs)

  # Get Y
  # For each covariate that is being plotted on the y axis
  # Convert the coefficient name to the column name
  # If they are equal then the data is not discontinuous and you can use the raw data as is and multiply it by the coefficient in the model
  # If they are not equal than the data is discontinuous, get the value for the data, set all but the levels equal to it to zero and multiply by the ceofficient from the model.
  vY = rep(coefficients(lmod)[["(Intercept)"]],dim(frmTmp)[1])
#  vY = rep(0,dim(frmTmp)[1])

  #Here we are not dealing with column names but, if factor data, the coefficient names
  for(iCvIndex in 1:length(lsCovariateToControlForNames))
  {
    sCurrentCovariate = lsCovariateToControlForNames[iCvIndex]
    #Get the column name of the current covariate (this must be used to compare to other column names)
    sCurCovariateColumnName = funcCoef2Col(sCurrentCovariate, frmTmp)

    #This is continuous data
    if(sCurrentCovariate == sCurCovariateColumnName)
    {
      vY = vY + dfdCoefs[sCurrentCovariate]*frmTmp[[sCurCovariateColumnName]]
    } else {
      #Discontinuous data
      # Get level
      xLevel = substr(sCurrentCovariate,nchar(sCurCovariateColumnName)+1,nchar(sCurrentCovariate))

      # Get locations where the data = level
      aiLevelIndices = rep(0,dim(frmTmp)[1])
      aiLevelIndices[which(frmTmp[sCurCovariateColumnName] == xLevel)]=1
      sCurrentCovariateBeta = dfdCoefs[sCurrentCovariate]
      if(is.na(sCurrentCovariateBeta)){sCurrentCovariateBeta=0}
      vY = vY + sCurrentCovariateBeta * aiLevelIndices
    }
  }
  #TODO based on transform   vY = vY+sin(residuals(lmod))^2
  if(!is.null(funcUnTransform))
  {
    vY = vY + funcUnTransform(residuals(lmod))
  } else {
    vY = vY + residuals(lmod) }

  # Plot x, raw data
  ## y label 
  sYLabel = paste(paste("B",lsCovariateToControlForNames,sep="*",collapse="+"),"e",sep="+")
  sTitle = "Partial Residual Plot"

  adCurXValues = frmTmp[[sCovariateOfInterest]]

  # If not plotting metadata that was originally NA then remove the imputed values here
  if(sCovariateOfInterest %in% names(liNaIndices)&&(length(liNaIndices[[sCovariateOfInterest]])>0))
  {
    adCurXValues = adCurXValues[-1*liNaIndices[[sCovariateOfInterest]]]
    vY <- vY[-1*liNaIndices[[sCovariateOfInterest]]]
    if(is.factor(adCurXValues)){adCurXValues = factor(adCurXValues)}
  }

  # Set the factor levels to include NA if they still exist
  # This is so if something is not imputed, then if there are NAs they will be plotted (to show no imputing)
  # Do not forget to keep te level order incase it was changed by the custom scripts.
  if( class( adCurXValues ) == "factor" )
  {
    vsLevels = levels(adCurXValues)
    if(sum(is.na(adCurXValues))>0)
    {
      adCurXValues = as.character(adCurXValues)
      adCurXValues[is.na(adCurXValues)]="NA"
      adCurXValues = factor(adCurXValues, levels=c(vsLevels,"NA"))
    }
  }

  # Scale to the original range
  if(!(class( adCurXValues ) == "factor" ))
  {
    vY = vY + mean(adCurXValues,rm.na=TRUE)
  }

  # Plot Partial Residual Plot
  # If we are printing discontinuous data
  # Get the color of the box plots
  # Plot box plots
  # Plot data as strip charts
  if(is.factor(adCurXValues))
  {
#    adCurXValues = factor(adCurXValues)
    astrColors = funcGetFactorBoxColors(adCurXValues,vY,adColorMin,adColorMax,adColorMed)
    asNames = c()
    for(sLevel in levels(adCurXValues))
    {
      asNames =  c(asNames,sprintf( "%s (%d)", sLevel, sum( adCurXValues == sLevel, na.rm = TRUE ) ))
    }

    plot(adCurXValues, vY, xlab=sCovariateOfInterest, ylab=sYLabel, names=asNames, notch = TRUE,mar = adMar,col = astrColors, main=sTitle, outpch = 4, outcex = 0.5 )
    stripchart( vY ~ adCurXValues, add = TRUE, col = astrColors, method = "jitter", vertical = TRUE, pch = 20 )

  } else {
    plot( adCurXValues, vY, mar = adMar, main = sTitle, xlab=sCovariateOfInterest, col = sprintf( "%s99", funcGetColor( ) ), pch = 20,ylab = sYLabel, xaxt = "s" )

    lmodLine = lm(vY~adCurXValues)

    dColor <- lmodLine$coefficients[2] * mean( adCurXValues, na.rm = TRUE ) / mean( vY, na.rm = TRUE )
    strColor <- sprintf( "%sDD", funcColor( dColor, adMax = adColorMin, adMin = adColorMax, adMed = adColorMed ) )
    abline( reg =lmodLine, col = strColor, lwd = 3 )
  }
}

funcBoostInfluencePlot <- function(
# Plot to show the rel.inf from boosting, what to know if the rank order is correct, better ranks for spiked data.
# Show the cut off and features identified as uneven.
vdRelInf, 
sFeature,
vsPredictorNames,
vstrKeepMetadata,
vstrUneven = c()
){
  vsCol = rep("black",length(vdRelInf))
  vsCol[which(vsPredictorNames %in% vstrKeepMetadata)]="green"
  vsCol[which(vsPredictorNames %in% vstrUneven)] = "orange"
  plot(vdRelInf, col=vsCol, main=sFeature, xlab="Index", ylab="Relative Influence")
  legend("topright", pch = paste(1:length(vsPredictorNames)), legend= vsPredictorNames, text.col=vsCol, col=vsCol)
}

funcResidualPlot <- function(
### Plot to data after confounding.
### That is, in a linear model with significant coefficient b1 for variable x1,
### that's been sparsified to some subset of terms: y = b0 + b1*x1 + sum(bi*xi)
### Plot x1 on the X axis, and instead of y on the Y axis, instead plot:
### y' = b0 + sum(bi*xi)
lsCur,
### Assocation to plot
frmeTmp,
### Data frame of orginal data
adColorMin,
### Min color in color range for markers
adColorMax,
### Max color in color range for markers
adColorMed,
### Medium color in color range for markers
adMar,
### Standardized margins
funcUnTransform,
### If a transform is used the opporite of that transfor must be used on the residuals in the partial residual plots
liNaIndices = c()
### Indices of NA data that was imputed
){
  #Now plot residual hat plot
  #Get coefficient names
  asAllCoefs = setdiff(names(lsCur$allCoefs),c("(Intercept)"))
  asAllColNames = c()
  for(sCoef in asAllCoefs)
  {
    asAllColNames = c(asAllColNames,funcCoef2Col(sCoef,frmeData=frmeTmp))
  }
  asAllColNames = unique(asAllColNames)

  # All coefficients except for the one of interest
  lsOtherCoefs = setdiff(asAllColNames, c(lsCur$name))

  lsCovariatesToPlot = NULL
  if(is.factor(lsCur$metadata))
  {
    lsCovariatesToPlot = paste(lsCur$name,levels(lsCur$metadata),sep="")
  }else{lsCovariatesToPlot=c(lsCur$orig)}

  # If there are no other coefficients then skip plot
#  if(!length(lsOtherCoefs)){return()}

  # Plot residuals
  funcResidualPlotHelper(frmTmp=frmeTmp, sResponseFeature=lsCur$taxon, lsFullModelCovariateNames=asAllColNames, lsCovariateToControlForNames=lsCovariatesToPlot, sCovariateOfInterest=lsCur$name, adColorMin=adColorMin, adColorMax=adColorMax, adColorMed=adColorMed, adMar=adMar, funcUnTransform=funcUnTransform, liNaIndices=liNaIndices)
}
