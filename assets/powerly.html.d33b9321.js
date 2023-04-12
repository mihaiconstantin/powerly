import{_ as p,o as c,c as i,a as e,b as n,w as l,d as o,e as s,r}from"../app.8d5e861e.mjs";const d={},D=o(`<h1 id="perform-sample-size-analysis" tabindex="-1"><a class="header-anchor" href="#perform-sample-size-analysis" aria-hidden="true">#</a> Perform Sample Size Analysis</h1><h2 id="description" tabindex="-1"><a class="header-anchor" href="#description" aria-hidden="true">#</a> Description</h2><p>Run an iterative three-step Monte Carlo method and return the sample sizes required to obtain a certain value for a performance measure of interest (e.g., sensitivity) given a set of hypothesized true model parameters (e.g., an edge weights matrix).</p><h2 id="usage" tabindex="-1"><a class="header-anchor" href="#usage" aria-hidden="true">#</a> Usage</h2><div class="language-r ext-r"><pre class="shiki" style="background-color:#1E1E1E;"><code><span class="line"><span style="color:#9CDCFE;">powerly</span><span style="color:#D4D4D4;">(</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">range_lower</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">range_upper</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">samples</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">30</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">replications</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">30</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">model</span><span style="color:#D4D4D4;"> = </span><span style="color:#CE9178;">&quot;ggm&quot;</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#569CD6;">...</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">model_matrix</span><span style="color:#D4D4D4;"> = </span><span style="color:#569CD6;">NULL</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">measure</span><span style="color:#D4D4D4;"> = </span><span style="color:#CE9178;">&quot;sen&quot;</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">statistic</span><span style="color:#D4D4D4;"> = </span><span style="color:#CE9178;">&quot;power&quot;</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">measure_value</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">0.6</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">statistic_value</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">0.8</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">monotone</span><span style="color:#D4D4D4;"> = </span><span style="color:#569CD6;">TRUE</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">increasing</span><span style="color:#D4D4D4;"> = </span><span style="color:#569CD6;">TRUE</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">spline_df</span><span style="color:#D4D4D4;"> = </span><span style="color:#569CD6;">NULL</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">solver_type</span><span style="color:#D4D4D4;"> = </span><span style="color:#CE9178;">&quot;quadprog&quot;</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">boots</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">10000</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">lower_ci</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">0.025</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">upper_ci</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">0.975</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">tolerance</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">50</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">iterations</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">10</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">cores</span><span style="color:#D4D4D4;"> = </span><span style="color:#569CD6;">NULL</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">backend_type</span><span style="color:#D4D4D4;"> = </span><span style="color:#569CD6;">NULL</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">save_memory</span><span style="color:#D4D4D4;"> = </span><span style="color:#569CD6;">FALSE</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">verbose</span><span style="color:#D4D4D4;"> = </span><span style="color:#569CD6;">TRUE</span></span>
<span class="line"><span style="color:#D4D4D4;">)</span></span>
<span class="line"></span></code></pre></div><h2 id="arguments" tabindex="-1"><a class="header-anchor" href="#arguments" aria-hidden="true">#</a> Arguments</h2>`,6),h=e("thead",null,[e("tr",null,[e("th",{style:{"text-align":"center"}},"Name"),e("th",{style:{"text-align":"left"}},"Description")])],-1),u=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"range_lower")]),e("td",{style:{"text-align":"left"}},"A single positive integer representing the lower bound of the candidate sample size range.")],-1),y=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"range_upper")]),e("td",{style:{"text-align":"left"}},"A single positive integer representing the upper bound of the candidate sample size range.")],-1),m=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"samples")]),e("td",{style:{"text-align":"left"}},"A single positive integer representing the number of sample sizes to select from the candidate sample size range.")],-1),g=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"replications")]),e("td",{style:{"text-align":"left"}},"A single positive integer representing the number of Monte Carlo replications to perform for each sample size selected from the candidate range.")],-1),f=e("td",{style:{"text-align":"center"}},[e("code",null,"model")],-1),_={style:{"text-align":"left"}},C=s("A character string representing the type of true model to find a sample size for. See the "),v=e("strong",null,[e("em",null,"True Models")],-1),b=s(" section for the function "),E=e("a",{href:"/reference/function/generate-model"},[e("code",null,"generate_model")],-1),x=s(" for possible values. Defaults to "),A=e("code",null,'"ggm"',-1),F=s("."),w=e("td",{style:{"text-align":"center"}},[e("code",null,"...")],-1),T={style:{"text-align":"left"}},k=s("Required arguments used for the generation of the true model. See the "),S=e("strong",null,[e("em",null,"True Models")],-1),q=s(" section for the function "),B=e("a",{href:"/reference/function/generate-model"},[e("code",null,"generate_model")],-1),z=s(" for the arguments required for each true model."),L=e("td",{style:{"text-align":"center"}},[e("code",null,"model_matrix")],-1),M={style:{"text-align":"left"}},U=s("A square matrix representing the true model. See the "),R=e("strong",null,[e("em",null,"True Models")],-1),N=s(" section for the function "),P=e("a",{href:"/reference/function/generate-model"},[e("code",null,"generate_model")],-1),$=s(" for what this matrix should look like depending on the true model selected."),I=e("td",{style:{"text-align":"center"}},[e("code",null,"measure")],-1),V={style:{"text-align":"left"}},j=s("A character string representing the type of performance measure of interest. Possible values are "),G=e("code",null,'"sen"',-1),O=s(" (i.e., sensitivity; the default), "),W=e("code",null,'"spe"',-1),H=s(" (i.e., specificity), "),J=e("code",null,'"mcc"',-1),K=s(" (i.e., Matthews correlation), and "),Q=e("code",null,'"rho"',-1),X=s(" (i.e., Pearson correlation). See the "),Y=e("strong",null,[e("em",null,"Performance Measures")],-1),Z=s(" section for the measures available for each type of true model supported."),ee=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"statistic")]),e("td",{style:{"text-align":"left"}},[s("A character string representing the type of statistic to be computed on the values obtained for the performance measures. Possible values are "),e("code",null,'"power"'),s(" (the default).")])],-1),se=e("td",{style:{"text-align":"center"}},[e("code",null,"measure_value")],-1),ne={style:{"text-align":"left"}},te=s("A single numerical value representing the desired value for the performance measure of interest. The default is "),le=e("code",null,"0.6",-1),ae=s(" (i.e., for the "),oe=e("code",null,'measure = "sen"',-1),re=s("). See the "),pe=e("strong",null,[e("em",null,"Performance Measures")],-1),ce=s(" section for the range of values allowed for each performance measure."),ie=e("td",{style:{"text-align":"center"}},[e("code",null,"statistic_value")],-1),de={style:{"text-align":"left"}},De=s("A single numerical value representing the desired value for the statistic of interest. The default is "),he=e("code",null,"0.8",-1),ue=s(" (i.e., for the "),ye=e("code",null,'statistic = "power"',-1),me=s("). See the "),ge=e("strong",null,[e("em",null,"Statistics")],-1),fe=s(" section for the range of values allowed for each statistic."),_e=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"monotone")]),e("td",{style:{"text-align":"left"}},[s("A logical value indicating whether a monotonicity assumption should be placed on the values of the performance measure. The default is "),e("code",null,"TRUE"),s(" meaning that the performance measure changes as a function of sample size (i.e., either by increasing or decreasing as the sample size goes up). The alternative "),e("code",null,"FALSE"),s(" indicates that the performance measure it is not assumed to change as a function a sample size.")])],-1),Ce=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"increasing")]),e("td",{style:{"text-align":"left"}},[s("A logical value indicating whether the performance measure is assumed to follow a non-increasing or non-decreasing trend. "),e("code",null,"TRUE"),s(" (the default) indicates a non-decreasing trend (i.e., the performance measure increases as the sample size goes up). "),e("code",null,"FALSE"),s(" indicates a non-increasing trend (i.e., the performance measure decreases as the sample size goes up).")])],-1),ve=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"spline_df")]),e("td",{style:{"text-align":"left"}},[s("A vector of positive integers representing the degrees of freedom considered for constructing the spline basis, or "),e("code",null,"NULL"),s(". The best degree of freedom is selected based on Leave One Out Cross-Validation. If "),e("code",null,"NULL"),s(" (the default) is provided, a vector of degrees of freedom is automatically created with all integers between "),e("code",null,"3"),s(" and "),e("code",null,"20"),s(".")])],-1),be=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"solver_type")]),e("td",{style:{"text-align":"left"}},[s("A character string representing the type of the quadratic solver used for estimating the spline coefficients. Currently only "),e("code",null,'"quadprog"'),s(" (the default) is supported.")])],-1),Ee=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"boots")]),e("td",{style:{"text-align":"left"}},[s("A positive integer representing the number of bootstrap runs to perform on the matrix of performance measures in order to obtained bootstrapped values for the statistic of interest. The default is "),e("code",null,"10000"),s(".")])],-1),xe=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"lower_ci")]),e("td",{style:{"text-align":"left"}},[s("A single numerical value indicating the lower bound for the confidence interval to be computed on the bootstrapped statistics. The default is "),e("code",null,"0.025"),s(" (i.e., "),e("span",{class:"katex"},[e("span",{class:"katex-html","aria-hidden":"true"},[e("span",{class:"base"},[e("span",{class:"strut",style:{height:"0.8056em","vertical-align":"-0.0556em"}}),e("span",{class:"mord"},"2.5%")])])]),s(").")])],-1),Ae=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"upper_ci")]),e("td",{style:{"text-align":"left"}},[s("A single numerical value indicating the upper bound for the confidence to be computed on the bootstrapped statistics. The default is "),e("code",null,"0.975"),s(" (i.e., "),e("span",{class:"katex"},[e("span",{class:"katex-html","aria-hidden":"true"},[e("span",{class:"base"},[e("span",{class:"strut",style:{height:"0.8056em","vertical-align":"-0.0556em"}}),e("span",{class:"mord"},"97.5%")])])]),s(").")])],-1),Fe=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"tolerance")]),e("td",{style:{"text-align":"left"}},[s("A single positive integer representing the width at the candidate sample size range at which the algorithm is considered to have converge. The default is "),e("code",null,"50"),s(", meaning that the algorithm will stop running when the difference between the upper and the lower bound of the candidate range shrinks to "),e("span",{class:"katex"},[e("span",{class:"katex-html","aria-hidden":"true"},[e("span",{class:"base"},[e("span",{class:"strut",style:{height:"0.6444em"}}),e("span",{class:"mord"},"50")])])]),s(" sample sizes.")])],-1),we=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"iterations")]),e("td",{style:{"text-align":"left"}},[s("A single positive integer representing the number of iterations the algorithm is allowed to run. The default is "),e("code",null,"10"),s(".")])],-1),Te=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"cores")]),e("td",{style:{"text-align":"left"}},[s("A single positive positive integer representing the number of cores to use for running the algorithm in parallel, or "),e("code",null,"NULL"),s(". If "),e("code",null,"NULL"),s(" (the default) the algorithm will run sequentially.")])],-1),ke=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"backend_type")]),e("td",{style:{"text-align":"left"}},[s("A character string indicating the type of cluster to create for running the algorithm in parallel, or "),e("code",null,"NULL"),s(". Possible values are "),e("code",null,'"psock"'),s(" and "),e("code",null,'"fork"'),s(". If "),e("code",null,"NULL"),s(" the backend is determined based on the computer architecture (i.e., "),e("code",null,"fork"),s(" for Unix and MacOS and "),e("code",null,"psock"),s(" for Windows).")])],-1),Se=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"save_memory")]),e("td",{style:{"text-align":"left"}},[s("A logical value indicating whether to save memory by only storing the results for the last iteration of the method. The default "),e("code",null,"TRUE"),s(" indicates that only the last iteration should be saved.")])],-1),qe=e("tr",null,[e("td",{style:{"text-align":"center"}},[e("code",null,"verbose")]),e("td",{style:{"text-align":"left"}},[s("A logical value indicating whether information about the status of the algorithm should be printed while running. The default is "),e("code",null,"TRUE"),s(".")])],-1),Be=e("h2",{id:"details",tabindex:"-1"},[e("a",{class:"header-anchor",href:"#details","aria-hidden":"true"},"#"),s(" Details")],-1),ze=s("This function represents the implementation of the method introduced by "),Le={href:"https://psyarxiv.com/j5v7u",target:"_blank",rel:"noopener noreferrer"},Me=s("Constantin et al. (2021)"),Ue=s(" for performing a priori sample size analysis (i.e., currently in the context of network models). The method takes the form of a three-step recursive algorithm designed to find an optimal sample size value given a model specification and an outcome measure of interest (e.g., sensitivity). It starts with a Monte Carlo simulation step for computing the outcome of interest at various sample sizes. It continues with a monotone non-decreasing curve-fitting step for interpolating the outcome. The final step employs a stratified bootstrapping scheme to account for the uncertainty around the recommendation provided. The method runs the three steps iteratively until the candidate sample size range used for the search shrinks below a specified value."),Re=e("h2",{id:"return",tabindex:"-1"},[e("a",{class:"header-anchor",href:"#return","aria-hidden":"true"},"#"),s(" Return")],-1),Ne=s("An "),Pe={href:"https://adv-r.hadley.nz/r6.html",target:"_blank",rel:"noopener noreferrer"},$e=e("code",null,"R6::R6Class",-1),Ie=o(" instance of <code>Method</code> class that contains the results for each step of the method for the last and previous iterations. Suppose that the output of the <code>powerly</code> function is stored in an <code>R</code> object called <code>results</code>. Specific fields of the <code>Method</code> class can be accessed from the instance <code>results</code> as <code>results$field</code>.",15),Ve=o("<p>The following main fields can be accessed:</p><ul><li><code>$duration</code>: The time in seconds elapsed during the method run.</li><li><code>$iteration</code>: The number of iterations performed.</li><li><code>$converged</code>: Whether the method converged.</li><li><code>$previous</code>: The results during the previous iteration.</li><li><code>$range</code>: The candidate sample size range.</li><li><code>$step_1</code>: The results for <em>Step 1</em>.</li><li><code>$step_2</code>: The results for <em>Step 2</em>.</li><li><code>$step_3</code>: The results for <em>Step 3</em>.</li><li><code>$recommendation</code>: The sample size recommendation(s).</li></ul>",2),je=s("The "),Ge=e("code",null,"plot",-1),Oe=s(),We={href:"https://adv-r.hadley.nz/oo.html",target:"_blank",rel:"noopener noreferrer"},He=e("code",null,"S3",-1),Je=s(" method"),Ke=s(" can be called on the return value to visualize the results. See the method "),Qe=e("a",{href:"/reference/method/plot-method"},[e("code",null,"plot.Method")],-1),Xe=s(" for more information on how to plot the method results. Briefly, the results for each individual step can be plotted as:"),Ye=o(`<div class="language-r ext-r"><pre class="shiki" style="background-color:#1E1E1E;"><code><span class="line"><span style="color:#6A9955;"># For Step 1.</span></span>
<span class="line"><span style="color:#DCDCAA;">plot</span><span style="color:#D4D4D4;">(</span><span style="color:#9CDCFE;">results</span><span style="color:#D4D4D4;">, </span><span style="color:#9CDCFE;">step</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">1</span><span style="color:#D4D4D4;">)</span></span>
<span class="line"></span>
<span class="line"><span style="color:#6A9955;"># For Step 2.</span></span>
<span class="line"><span style="color:#DCDCAA;">plot</span><span style="color:#D4D4D4;">(</span><span style="color:#9CDCFE;">results</span><span style="color:#D4D4D4;">, </span><span style="color:#9CDCFE;">step</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">2</span><span style="color:#D4D4D4;">)</span></span>
<span class="line"></span>
<span class="line"><span style="color:#6A9955;"># For Step 3.</span></span>
<span class="line"><span style="color:#DCDCAA;">plot</span><span style="color:#D4D4D4;">(</span><span style="color:#9CDCFE;">results</span><span style="color:#D4D4D4;">, </span><span style="color:#9CDCFE;">step</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">3</span><span style="color:#D4D4D4;">)</span></span>
<span class="line"></span></code></pre></div><h2 id="performance-measures" tabindex="-1"><a class="header-anchor" href="#performance-measures" aria-hidden="true">#</a> Performance Measures</h2><table><thead><tr><th style="text-align:left;">Performance Measure</th><th style="text-align:center;">Symbol</th><th style="text-align:right;">Lower</th><th style="text-align:right;">Upper</th><th style="text-align:center;">Compatible Models</th></tr></thead><tbody><tr><td style="text-align:left;">Sensitivity</td><td style="text-align:center;"><code>sen</code></td><td style="text-align:right;"><code>0.00</code></td><td style="text-align:right;"><code>1.00</code></td><td style="text-align:center;"><code>ggm</code></td></tr><tr><td style="text-align:left;">Specificity</td><td style="text-align:center;"><code>spe</code></td><td style="text-align:right;"><code>0.00</code></td><td style="text-align:right;"><code>1.00</code></td><td style="text-align:center;"><code>ggm</code></td></tr><tr><td style="text-align:left;">Matthews correlation</td><td style="text-align:center;"><code>mcc</code></td><td style="text-align:right;"><code>-1.00</code></td><td style="text-align:right;"><code>1.00</code></td><td style="text-align:center;"><code>ggm</code></td></tr><tr><td style="text-align:left;">Pearson correlation</td><td style="text-align:center;"><code>rho</code></td><td style="text-align:right;"><code>-1.00</code></td><td style="text-align:right;"><code>1.00</code></td><td style="text-align:center;"><code>ggm</code></td></tr></tbody></table>`,3),Ze=s("See the "),es=e("strong",null,[e("em",null,"True Models")],-1),ss=s(" section for the "),ns=e("a",{href:"/reference/function/generate-model"},[e("code",null,"generate_model")],-1),ts=s(" function for more information on the compatible true models."),ls=o(`<h2 id="statistics" tabindex="-1"><a class="header-anchor" href="#statistics" aria-hidden="true">#</a> Statistics</h2><table><thead><tr><th style="text-align:left;">Statistic</th><th style="text-align:center;">Symbol</th><th style="text-align:right;">Lower</th><th style="text-align:right;">Upper</th></tr></thead><tbody><tr><td style="text-align:left;">Power</td><td style="text-align:center;"><code>power</code></td><td style="text-align:right;"><code>0.00</code></td><td style="text-align:right;"><code>1.00</code></td></tr></tbody></table><h2 id="examples" tabindex="-1"><a class="header-anchor" href="#examples" aria-hidden="true">#</a> Examples</h2><div class="language-r ext-r line-numbers-mode"><pre class="shiki" style="background-color:#1E1E1E;"><code><span class="line"><span style="color:#6A9955;"># Suppose we want to find the sample size for observing a sensitivity of \`0.6\`</span></span>
<span class="line"><span style="color:#6A9955;"># with a probability of \`0.8\`, for a GGM true model consisting of \`10\` nodes</span></span>
<span class="line"><span style="color:#6A9955;"># with an edge density of \`0.4\`.</span></span>
<span class="line"></span>
<span class="line"><span style="color:#6A9955;"># We can run the method for an arbitrarily generated true model that matches</span></span>
<span class="line"><span style="color:#6A9955;"># those characteristics (i.e., number of nodes and edge density).</span></span>
<span class="line"><span style="color:#9CDCFE;">results</span><span style="color:#D4D4D4;"> &lt;- </span><span style="color:#9CDCFE;">powerly</span><span style="color:#D4D4D4;">(</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">range_lower</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">300</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">range_upper</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">1000</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">samples</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">40</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">replications</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">40</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">measure</span><span style="color:#D4D4D4;"> = </span><span style="color:#CE9178;">&quot;sen&quot;</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">statistic</span><span style="color:#D4D4D4;"> = </span><span style="color:#CE9178;">&quot;power&quot;</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">measure_value</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">.6</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">statistic_value</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">.8</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">model</span><span style="color:#D4D4D4;"> = </span><span style="color:#CE9178;">&quot;ggm&quot;</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">nodes</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">10</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">density</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">.4</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">cores</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">4</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">verbose</span><span style="color:#D4D4D4;"> = </span><span style="color:#569CD6;">TRUE</span></span>
<span class="line"><span style="color:#D4D4D4;">)</span></span>
<span class="line"></span>
<span class="line"><span style="color:#6A9955;"># Or we omit the \`nodes\` and \`density\` arguments and specify directly the edge</span></span>
<span class="line"><span style="color:#6A9955;"># weights matrix via the \`model_matrix\` argument.</span></span>
<span class="line"></span>
<span class="line"><span style="color:#6A9955;"># To get a matrix of edge weights we can use the \`generate_model()\` function.</span></span>
<span class="line"><span style="color:#9CDCFE;">true_model</span><span style="color:#D4D4D4;"> &lt;- </span><span style="color:#9CDCFE;">generate_model</span><span style="color:#D4D4D4;">(</span><span style="color:#9CDCFE;">type</span><span style="color:#D4D4D4;"> = </span><span style="color:#CE9178;">&quot;ggm&quot;</span><span style="color:#D4D4D4;">, </span><span style="color:#9CDCFE;">nodes</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">10</span><span style="color:#D4D4D4;">, </span><span style="color:#9CDCFE;">density</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">.4</span><span style="color:#D4D4D4;">)</span></span>
<span class="line"></span>
<span class="line"><span style="color:#6A9955;"># Then, supply the true model to the algorithm directly.</span></span>
<span class="line"><span style="color:#9CDCFE;">results</span><span style="color:#D4D4D4;"> &lt;- </span><span style="color:#9CDCFE;">powerly</span><span style="color:#D4D4D4;">(</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">range_lower</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">300</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">range_upper</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">1000</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">samples</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">40</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">replications</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">40</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">measure</span><span style="color:#D4D4D4;"> = </span><span style="color:#CE9178;">&quot;sen&quot;</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">statistic</span><span style="color:#D4D4D4;"> = </span><span style="color:#CE9178;">&quot;power&quot;</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">measure_value</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">.6</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">statistic_value</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">.8</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">model</span><span style="color:#D4D4D4;"> = </span><span style="color:#CE9178;">&quot;ggm&quot;</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">model_matrix</span><span style="color:#D4D4D4;"> = </span><span style="color:#9CDCFE;">true_model</span><span style="color:#D4D4D4;">, </span><span style="color:#6A9955;"># Note the change.</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">cores</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">4</span><span style="color:#D4D4D4;">,</span></span>
<span class="line"><span style="color:#D4D4D4;">    </span><span style="color:#9CDCFE;">verbose</span><span style="color:#D4D4D4;"> = </span><span style="color:#569CD6;">TRUE</span></span>
<span class="line"><span style="color:#D4D4D4;">)</span></span>
<span class="line"></span>
<span class="line"><span style="color:#6A9955;"># To visualize the results, we can use the \`plot\` S3 method and indicate the</span></span>
<span class="line"><span style="color:#6A9955;"># step that we want to plot.</span></span>
<span class="line"><span style="color:#DCDCAA;">plot</span><span style="color:#D4D4D4;">(</span><span style="color:#9CDCFE;">results</span><span style="color:#D4D4D4;">, </span><span style="color:#9CDCFE;">step</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">1</span><span style="color:#D4D4D4;">)</span></span>
<span class="line"><span style="color:#DCDCAA;">plot</span><span style="color:#D4D4D4;">(</span><span style="color:#9CDCFE;">results</span><span style="color:#D4D4D4;">, </span><span style="color:#9CDCFE;">step</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">2</span><span style="color:#D4D4D4;">)</span></span>
<span class="line"><span style="color:#DCDCAA;">plot</span><span style="color:#D4D4D4;">(</span><span style="color:#9CDCFE;">results</span><span style="color:#D4D4D4;">, </span><span style="color:#9CDCFE;">step</span><span style="color:#D4D4D4;"> = </span><span style="color:#B5CEA8;">3</span><span style="color:#D4D4D4;">)</span></span>
<span class="line"></span>
<span class="line"><span style="color:#6A9955;"># To see a summary of the results, we can use the \`summary\` S3 method.</span></span>
<span class="line"><span style="color:#DCDCAA;">summary</span><span style="color:#D4D4D4;">(</span><span style="color:#9CDCFE;">results</span><span style="color:#D4D4D4;">)</span></span>
<span class="line"></span></code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div></div></div><h2 id="see-also" tabindex="-1"><a class="header-anchor" href="#see-also" aria-hidden="true">#</a> See Also</h2><p>Functions <a href="/reference/function/generate-model"><code>generate_model</code></a> and <a href="/reference/function/validate"><code>validate</code></a>.</p><p><code>S3</code> methods <a href="/reference/method/plot-method"><code>plot.Method</code></a> and <a href="/reference/method/summary"><code>summary</code></a>.</p><h2 id="requests" tabindex="-1"><a class="header-anchor" href="#requests" aria-hidden="true">#</a> Requests</h2>`,8),as=s("If you would like to support a new model, performance measure, or statistic, please open a pull request on GitHub at "),os={href:"https://github.com/mihaiconstantin/powerly/pulls",target:"_blank",rel:"noopener noreferrer"},rs=s("github.com/mihaiconstantin/powerly/pulls"),ps=s("."),cs=s("To request a new model, performance measure, or statistic, please submit your request at "),is={href:"https://github.com/mihaiconstantin/powerly/issues",target:"_blank",rel:"noopener noreferrer"},ds=s("github.com/mihaiconstantin/powerly/issues"),Ds=s(". If possible, please also include references discussing the topics you are requesting. Alternatively, you can get in touch at "),hs=e("code",null,"mihai at mihaiconstantin dot com",-1),us=s("."),ys=e("h2",{id:"references",tabindex:"-1"},[e("a",{class:"header-anchor",href:"#references","aria-hidden":"true"},"#"),s(" References")],-1),ms={class:"references"},gs=s("Constantin, M., Schuurman, N. K., & Vermunt, J. (2021). A General Monte Carlo Method for Sample Size Analysis in the Context of Network Models. "),fs={href:"https://doi.org/10.31234/osf.io/j5v7u",target:"_blank",rel:"noopener noreferrer"},_s=s("https://doi.org/10.31234/osf.io/j5v7u");function Cs(vs,bs){const t=r("RouterLink"),a=r("ExternalLinkIcon");return c(),i("div",null,[D,e("table",null,[h,e("tbody",null,[u,y,m,g,e("tr",null,[f,e("td",_,[C,n(t,{to:"/reference/function/generate-model.html#true-models"},{default:l(()=>[v]),_:1}),b,E,x,A,F])]),e("tr",null,[w,e("td",T,[k,n(t,{to:"/reference/function/generate-model.html#true-models"},{default:l(()=>[S]),_:1}),q,B,z])]),e("tr",null,[L,e("td",M,[U,n(t,{to:"/reference/function/generate-model.html#true-models"},{default:l(()=>[R]),_:1}),N,P,$])]),e("tr",null,[I,e("td",V,[j,G,O,W,H,J,K,Q,X,n(t,{to:"/reference/function/powerly.html#performance-measures"},{default:l(()=>[Y]),_:1}),Z])]),ee,e("tr",null,[se,e("td",ne,[te,le,ae,oe,re,n(t,{to:"/reference/function/powerly.html#performance-measures"},{default:l(()=>[pe]),_:1}),ce])]),e("tr",null,[ie,e("td",de,[De,he,ue,ye,me,n(t,{to:"/reference/function/powerly.html#statistics"},{default:l(()=>[ge]),_:1}),fe])]),_e,Ce,ve,be,Ee,xe,Ae,Fe,we,Te,ke,Se,qe])]),Be,e("p",null,[ze,e("a",Le,[Me,n(a)]),Ue]),Re,e("p",null,[Ne,e("a",Pe,[$e,n(a)]),Ie]),Ve,e("p",null,[je,Ge,Oe,e("a",We,[He,Je,n(a)]),Ke,Qe,Xe]),Ye,e("p",null,[Ze,n(t,{to:"/reference/function/generate-model.html#true-models"},{default:l(()=>[es]),_:1}),ss,ns,ts]),ls,e("p",null,[as,e("a",os,[rs,n(a)]),ps]),e("p",null,[cs,e("a",is,[ds,n(a)]),Ds,hs,us]),ys,e("div",ms,[e("p",null,[gs,e("a",fs,[_s,n(a)])])])])}const xs=p(d,[["render",Cs],["__file","powerly.html.vue"]]);export{xs as default};
