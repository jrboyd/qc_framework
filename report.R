#build a nice spreadsheet of various qc metrics for qc_framework output
#setup and run diffbind
wd = getwd()
outdir= normalizePath("output")

setwd(outdir)
sample_ids = read.table("tmp.sample_ids", stringsAsFactors = F)[,1]
pooled_ids = paste0(unique(read.table("tmp.pooled_ids"))[,1], "_pooled")

###report on unpooled samples
sample_tightPeaks = read.table("tight_rep_peak_counts.txt", row.names = 2)
sample_loosePeaks = read.table("loose_rep_peak_counts.txt", row.names = 2)
all_stats = list()
for(samp in sample_ids){
  #locate report files
  fastq_rep_file = dir(samp, pattern = "report_fastq$", full.names = T)
  align_rep_file = dir(samp, pattern = "bam\\.log$", full.names = T)
  #parse fastq report
  fastq_rep = read.table(fastq_rep_file, row.names = 1, stringsAsFactors = F)
  stats = list()
  stats$gz_loc = fastq_rep["gz_filename",]
  stats$gz_md5sum = fastq_rep["gz_md5sum",]
  stats$raw_reads = fastq_rep["raw_reads",]
  stats$tc_reads = fastq_rep["tc_reads",]
  #parse alignment report
  align_rep1 = read.table(align_rep_file, row.names = 1, stringsAsFactors = F, sep = "|", skip = 7, nrows = 14)
  align_rep2 = read.table(align_rep_file, row.names = 1, stringsAsFactors = F, sep = "|", skip = 22, nrows = 4)
  align_rep3 = read.table(align_rep_file, row.names = 1, stringsAsFactors = F, sep = "|", skip = 27, nrows = 3)
  stats$uniq_mapped = align_rep1[1,]
  stats$multi_mapped = align_rep2[1,]
  stats$mismatch_rate = align_rep1[10,]
  stats$deletion_rate = align_rep1[11,]
  stats$insertion_rate = align_rep1[13,]
  stats = lapply(stats, function(x)sub("\t", "", x))#stupid tabs
  n_loose = "----"#default values applied to input samples
  n_tight = "----"
  if(!grepl("input", samp)){
    #parse peak report
    keep = grepl(samp, rownames(sample_loosePeaks))
    n_loose = sample_loosePeaks[keep,]
    keep = grepl(samp, rownames(sample_tightPeaks))
    n_tight = sample_tightPeaks[keep,]
  }
  stats$loose_peaks = n_loose
  stats$tight_peaks = n_tight
  all_stats[[samp]] = stats
}

nrow = length(all_stats)
ncol = length(all_stats[[1]])
final = matrix("", nrow = nrow, ncol = ncol)
rownames(final) = names(all_stats)
colnames(final) = names(all_stats[[1]])
for(s in names(all_stats)){
  final[s,] = unlist(all_stats[[s]])
}

samples_report = final

###report on pooled samples
pooled_tightPeaks = read.table("tight_pooled_peak_counts.txt", row.names = 2)

all_stats = list()
for(samp in pooled_ids){
  stats = list()
  if(grepl("input", samp)){
    blank = "----"
    stats$reads_in_peaks = blank
    stats$total_aligned_reads = blank
    stats$FRIP = blank
    stats$reads_in_peaks = blank
    stats$total_aligned_reads = blank
    stats$FRIP = blank
    for( v in c("01", "05", "1", "15", "2", "25")){
      stats[[paste0("idr", v) ]] = blank
    }
  }else{
    frip_file = dir(samp, pattern = "FRIP.txt$", full.names = T)
    frip = read.table(frip_file, stringsAsFactors = F, row.names = 1)[1,, drop = F]
    stats$reads_in_peaks = frip[,1]
    stats$total_aligned_reads = frip[,2]
    stats$FRIP = frip[,3]
    
    idr_file = dir(samp, pattern = "aboveIDR.txt$", full.names = T)
    idr = read.table(idr_file, stringsAsFactors = F, row.names = 3)[,3, drop = F]
    for( v in c("01", "05", "1", "15", "2", "25")){
      stats[[paste0("idr", v) ]] = idr[paste0("0.", v),]
    }
  }
  cor_file = "bamCorrelate_values.txt"
  cor = read.table(cor_file)
  tmp = strsplit(samp, "_")[[1]]#cut off pooled to get key
  key = paste(tmp[-length(tmp)], collapse = "_")
  keep = grepl(rownames(cor), pattern = key)
  sub = cor[keep,keep, drop = F]
  if(nrow(sub) == 1){
  val = "1rep"
  }else if(nrow(sub) == 2){
    val = sub[1,2]
  }else{
    stop("corr of > 2 samples not supported")
  }
  stats$bamCorr = val
  
  all_stats[[samp]] = stats
}

nrow = length(all_stats)
ncol = length(all_stats[[1]])
final = matrix("", nrow = nrow, ncol = ncol)
rownames(final) = names(all_stats)
colnames(final) = names(all_stats[[1]])
for(s in names(all_stats)){
  final[s,] = unlist(all_stats[[s]])
}
pooled_report = final

###report on feature distribution
remove("final")
all_stats = list()
for(samp in sample_ids){
  if(grepl("input", samp)){
    next
  }
  stats = list()
  features_file = dir(samp, pattern = "feature_distribution.txt", full.names = T)
  features = read.table(features_file, stringsAsFactors = F, row.names = 2)
  rownames(features) = sapply(rownames(features), basename)
  keep = grepl(rownames(features), pattern = "\\.out\\.")
  features = features[keep,, drop = F]
  rownames(features) = sapply(rownames(features), function(x){
    strsplit(x, "\\.")[[1]][2]
  })
  colnames(features) = samp
  if(!exists("final")){
    final = features
  }else{
    final = cbind(final, features)
  }
}
for(samp in pooled_ids){
  if(grepl("input", samp)){
    next
  }
  stats = list()
  features_file = dir(samp, pattern = "feature_distribution.txt", full.names = T)
  features = read.table(features_file, stringsAsFactors = F, row.names = 2)
  rownames(features) = sapply(rownames(features), basename)
  keep = grepl(rownames(features), pattern = "\\.out\\.")
  features = features[keep,, drop = F]
  rownames(features) = sapply(rownames(features), function(x){
    strsplit(x, "\\.")[[1]][2]
  })
  colnames(features) = samp
  if(!exists("final")){
    final = features
  }else{
    final = cbind(final, features)
  }
}
features_reports = final