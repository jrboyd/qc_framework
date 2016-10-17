#build a nice spreadsheet of various qc metrics for qc_framework output
#setup and run diffbind
wd = getwd()
outdir= normalizePath("output_drugs")

setwd(outdir)
sample_ids = read.table("tmp.sample_ids", stringsAsFactors = F)[,1]
pooled_ids = paste0(unique(read.table("tmp.pooled_ids"))[,1], "_pooled")

###report on unpooled samples
sample_tightPeaks = read.table("tight_rep_peak_counts.txt", row.names = 2)
sample_loosePeaks = read.table("loose_rep_peak_counts.txt", row.names = 2)
all_stats = list()
for(samp in sample_ids){
  print(samp)
  #locate report files
  fastq_rep_file = dir(samp, pattern = "report_fastq$", full.names = T)
  align_rep_file = dir(samp, pattern = "bam\\.log$", full.names = T)
  #parse fastq report
#  print(paste0(outdir, "/", fastq_rep_file))
  print(fastq_rep_file)
  n = 5
  fastq_rep = matrix(0, nrow = n, ncol = 1)
  rownames(fastq_rep) = 1:n
  for(i in 1:n){
    tmp = as.matrix(read.table(fastq_rep_file, stringsAsFactors = F, skip = i - 1, nrows = 1))[1,]
    rownames(fastq_rep)[i] = tmp[1]
    if(length(tmp) == 2){
      fastq_rep[i, 1] = tmp[2]
    }
  }
#  fastq_rep = read.table(fastq_rep_file, row.names = 1, stringsAsFactors = F)
  print(fastq_rep)
  stats = list()
  stats$gz_loc = fastq_rep["gz_filename",]
  stats$gz_md5sum = fastq_rep["gz_md5sum",]
  stats$raw_reads = fastq_rep["raw_reads",]
  stats$tc_reads = fastq_rep["tc_reads",]
  #parse alignment report
  #print(paste0(outdir, "/", align_rep_file))
  print(align_rep_file)
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
  frip_rip = "----"
  frip_ar = "----"
  frip_val = "----"
  if( !grepl("input", samp)){
    #parse peak report
    keep = grepl(samp, rownames(sample_loosePeaks))
    n_loose = sample_loosePeaks[keep,]
    keep = grepl(samp, rownames(sample_tightPeaks))
    n_tight = sample_tightPeaks[keep,]
    frip_file = dir(samp, pattern = "_FRIP.txt", full.names = T)
    print(frip_file)
    frip = read.table(frip_file, stringsAsFactors = F, row.names = 1)[1,, drop = F]
    frip_rip = frip[,1]
    frip_ar = frip[,2]
    frip_val = frip[,3]
  }
  stats$loose_peaks = n_loose
  stats$tight_peaks = n_tight
  stats$reads_in_peaks = frip_rip
  stats$total_aligned_reads = frip_ar
  stats$FRIP = frip_val

  all_stats[[samp]] = stats
}
print("finalize reps")
nrow = length(all_stats)
ncol = length(all_stats[[1]])
final = matrix("", nrow = nrow, ncol = ncol)
rownames(final) = names(all_stats)
colnames(final) = names(all_stats[[1]])
for(s in names(all_stats)){
  print(s)
  #print(all_stats[[s]])
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
    stats$tight_peaks =  blank
    for( v in c("01", "05", "1", "15", "2", "25")){
      stats[[paste0("idr", v) ]] = blank
    }
  }else{
    print(samp)
    frip_file = dir(samp, pattern = "FRIP.txt$", full.names = T)
    print(paste0(outdir, "/", frip_file))
    frip = read.table(frip_file, stringsAsFactors = F, row.names = 1)[1,, drop = F]
    stats$reads_in_peaks = frip[,1]
    stats$total_aligned_reads = frip[,2]
    stats$FRIP = frip[,3]
    
    keep = grepl(samp, rownames(pooled_tightPeaks))
    n_tight = pooled_tightPeaks[keep,]
    stats$tight_peaks = n_tight

    idr_file = dir(samp, pattern = "aboveIDR.txt$", full.names = T)
    print(paste0(outdir, "/", idr_file))
    idr = read.table(idr_file, stringsAsFactors = F, row.names = 3)[,3, drop = F]
    for( v in c("01", "05", "1", "15", "2", "25")){
      stats[[paste0("idr", v) ]] = idr[paste0("0.", v),]
    }
  }
  
  all_stats[[samp]] = stats
}
print("pool")
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
  print(samp) 
  features_file = dir(paste0(samp, "/peaks_by_location"), pattern = "feature_distribution.txt", full.names = T)
  print(paste0(outdir, "/", features_file))
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
  features_file = dir(paste0(samp, "/peaks_by_location"), pattern = "feature_distribution.txt", full.names = T)
  print(paste0(outdir, "/", features_file))
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


cor_file = dir(pattern = "bamCorrelate_values.txt")
bamCorr = read.table(cor_file)

save(features_reports, pooled_report, samples_report, bamCorr, file = paste0(outdir, "_report.save"))
