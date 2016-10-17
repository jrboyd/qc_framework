#!/bin/bash
WD=/slipstream/galaxy/uploads/working/qc_framework/output_drugs_with_merged_inputs
SCRIPT_DIR=/slipstream/galaxy/uploads/working/qc_framework/analysis_scripts
TEMPLATE=$WD/diffbind_template.R
if [ ! -f $TEMPLATE ]; then
  cp $SCRIPT_DIR/diffbind_template.R $TEMPLATE
fi
marks=(H3K4ME3 H3K4AC H3K27ME3 H3K27AC) # H4K20ME3 H4K12AC)
for m in ${marks[@]}; do
  new=${TEMPLATE/template/$m}
  echo $new
  cp $TEMPLATE $new
  sed "s/-MARK-/$m/g" $TEMPLATE > $new
  cfg=diffbind_configs\\/diffbind_config_"$m".csv
  sed -i "s/-CONFIG-/$cfg/g" $new
  qsub -wd $WD -v SCRIPT=$new $SCRIPT_DIR/run_diffbind.sh
done


