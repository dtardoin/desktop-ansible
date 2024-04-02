export PATH="/usr/local/opt/go@1.15/bin:$HOME/bin/:/usr/local/opt/libpq/bin:$PATH"
#export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
export PATH="/usr/local/Cellar/coreutils/9.1/libexec/gnubin/csplit:$PATH"
  export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Fixes issue in zsh that will blow up when you try to use brackets in tf state comands
setopt +o nomatch


export TELEPORT_PROXY="dbtlabs.teleport.sh"
export TELEPORT_AUTH="okta"

export ZSH="/Users/davidardoin/.oh-my-zsh"
export GOBIN="~/bin/"
ZSH_THEME="clean"
plugins=(
  git
  aws
  kubectl
  web-search
  jsontools
  macos
)
source $ZSH/oh-my-zsh.sh



source ~/.zsh-secrets
alias ls=exa
alias drain_and_dec="~/Repositories/dev-tools/scripts/k8s_node_drain_and_decrement.sh"
alias newiterm="open -n -a /Applications/iTerm.app"
alias myip="curl ifconfig.me"
alias asl="AWS_PROFILE=default aws sso login"
alias drop_infra="cd ~/Repositories/infra"
alias drop_code="cd ~/Repositories/code"
alias tf="terraform"
alias tfi="rm -f .terraform.lock.hcl && terraform init"
alias tfip="rm -f .terraform.lock.hcl && tfi && tfp"
alias tfa="terraform apply"
alias tfp="terraform plan"
alias tfu="terraform force-unlock"
alias tfc="terraform console"
#terraform force-unlock $(tfp 2>&1|grep "ID:"|sed 's/  *ID:  *//')'
alias tfss="terraform state show"
alias tfsl="terraform state list"
alias gpo="git pull origin" 
#alias gpom="gpo master"
alias gcomm="gcom && gpom"
alias gs="git status"
alias gpco="gpc origin"
alias wea="curl wttr.in/~Red+Bank+Tennessee"
# alias kc="kubectl"
# Due to profile also now needing to be set
# alias uk="unset KUBECONTEXT"
alias kg="kc get"
alias kcu="kc-update"
alias kcn="kc-name"
alias kdn='kc describe node'
alias kots="kc kots"
alias kc-list="kc config get-contexts -o name"
alias az-list="az account list|jq -r '.[]| .name + \": \" + .id'"
alias zreload="source ~/.zshrc"
alias zl="source ~/.zshrc"
alias zedit="vim ~/.zshrc"
alias ze="vim ~/.zshrc"
alias asgi="aws sts get-caller-identity"
alias sed='gsed'
alias updater="$HOME/Repositories/dev-tools/scripts/k8s_update_version/.venv/k8s/bin/python $HOME/Repositories/dev-tools/scripts/k8s_update_version/main.py"
alias k8s-upgrade="$HOME/Repositories/dev-tools/scripts/st-k8s-upgrade/venv/bin/python $HOME/Repositories/dev-tools/scripts/st-k8s-upgrade/upgrade.py"
alias k8s-cleanup="$HOME/Repositories/dev-tools/scripts/st-k8s-upgrade/venv/bin/python $HOME/Repositories/dev-tools/scripts/st-k8s-upgrade/cleanup.py"
function gpom () {
    git pull origin master || git pull origin main  
}
function gcom () {
    git checkout master || git checkout main  
}
ggo () {
    origin=$(git remote get-url origin --push) 
    open_command ${origin/git\@/https://}
}
function kc-testpod () {
  rand=$(openssl rand -hex 3)

  if [ -z "$1" ] || ([ -z "$2" ] && [ $1 =~ "nosecret" ]); then 
    cmd="apk add curl busybox-extras drill openssh-client-default tcpdump postgresql-client && /bin/ash"
  else
    cmd="${1}"
  fi 

  if [[ $1 =~ "nosecret" ]]; then 
    secrets=""
  else 
    secrets=",\"envFrom\": [
                {
                  \"secretRef\": {
                  \"name\": \"dbt-cloud-app-secrets\"
                  },
                  \"secretRef\": {
                  \"name\": \"dbt-cloud-database-secrets\"
                  }
                }
              ]"
  fi  
  
  json="{
    \"spec\": {
        \"containers\": [
            {
                \"args\": [
                    \"/bin/ash\",
                    \"-c\",
                    \"$cmd\"
                ],
                \"image\": \"alpine:latest\",
                \"name\": \"davidtest-${rand}\",
                \"stdin\": true,
                \"stdinOnce\": true,
                \"tty\": true
                ${secrets}
            }
        ]
    }

}"
echo $json
  kc run -i -t --rm "davidtest-${rand}" --image=alpine:latest --overrides="$json"
}
function tffu() {
    terraform force-unlock $(tfp -target=shouldnot.exist 2>&1|grep "ID:"|sed "s/  *ID:  *//")
}


function go-infra() {
  if [[ "$1" ==  "st" ]]; then
   cd ~/Repositories/dbt-cloud-infra-single-tenant
  elif [[ "$1" ==  "mt" ]]; then
   cd ~/Repositories/dbt-cloud-infra-terraform
  elif [ -n "$1" ]; then
      exact_dir=$(find ~/Repositories -name ${1} -type dir -maxdepth 1)
      dir=$(find ~/Repositories -name "*${1}*" -type dir -maxdepth 1)
      if [ $(echo $exact_dir | wc -w) -eq 1 ]; then 
         cd $exact_dir 
      elif [ $(echo $dir|wc -w) -gt 1 ] || [[ "${dir}" == "" ]]; then
        echo "can't find that directory..."
      else
        cd $dir
      fi
  else
    cd ~/Repositories
  fi
}

function repo() {
  go-infra $1
}

function mt() {
  if [ -z $1 ] ; then 
   cd ~/Repositories/dbt-cloud-infra-terraform
  else
    dirs=$(find ~/Repositories/dbt-cloud-infra-terraform/accounts -name "*${1}*" -type d -depth 1)
    echo $dirs
    if [ $(echo $dirs |wc -l) -gt 1 ]; then 
      echo "more than one directory found, exiting..."
      echo $dirs
      exit 1
    elif [ $(echo $dirs |wc -l) -eq 0 ]; then 
      echo "no directories found, exiting..."
      exit 1
    else
      cd $dirs
    fi

  fi
}
function go-st() {
  if [ -z $1 ]; then  
    cd ~/Repositories/dbt-cloud-infra-single-tenant
  elif [[ $1 == "jump" ]]; then 
    cd ~/Repositories/dbt-cloud-infra-single-tenant/common/aws/dbt-labs-jump
  elif [[ $1 == "globals" || $1 == "global" ]]; then 
    cd ~/Repositories/dbt-cloud-infra-single-tenant/common/aws/globals
 elif [[ $1 == "azure" || $1 == "az" ]]; then 
    cd ~/Repositories/dbt-cloud-infra-single-tenant/azure/accounts
 elif [[ $1 == "aws" ]]; then 
    cd ~/Repositories/dbt-cloud-infra-single-tenant/aws/accounts
  else
    if [[ $1 == "staging" ]] && [[ -n $2 ]]; then 
        dir=$(find ~/Repositories/dbt-cloud-infra-single-tenant/${2}/accounts/ -name "*${1}*" -type dir -maxdepth 1)
    elif [[ $1 == "staging" ]] && [[ -z $2 ]]; then 
        echo "staging requires a second argument..."
    else
        aws_dir=$(find ~/Repositories/dbt-cloud-infra-single-tenant/aws/accounts -regex ".\{0,\}${1}[a-z]\{0,\}$" -path *customer* -type dir -maxdepth 3)
        az_dir=$(find ~/Repositories/dbt-cloud-infra-single-tenant/azure/accounts -regex ".\{0,\}${1}[a-z]\{0,\}$" -type dir -maxdepth 2)
        if [ ! -z $aws_dir ] && [ -z $az_dir ] ; then 
            dir=$aws_dir
        elif [ ! -z $az_dir ] && [ -z $aws_dir ] ; then 
            dir=$az_dir
        elif [ -z $az_dir ] && [ -z $aws_dir ]; then 
          echo "can't find that directory..."
        else 
          echo "more than one directory"
          echo "AWS: ${aws_dir}"
          echo "Azure: ${az_dir}"
        fi
    fi

    if [ $(echo $dir|wc -l) -gt 1 ] || [ "${dir}" = "" ]; then
      echo "can't find that directory..."
    else
      cd $dir
    fi
  fi
}
function st() {
  go-st $1 $2
}

function hm () {
  target=$1
  base_dir="$HOME/Repositories/helm-charts"
  if [ -z $1 ]; then 
     cd ~/Repositories/helm-charts 
  elif [[ $1 == "app " ]]; then 
    cd "${base_dir}/charts/dbt-cloud-app"
  else 
    dir=$(find $base_dir -name "*${1}*" -type d -not -path "*.git*" -not -path "*devspace*" -not -path "*scripts*")

    if [ $(echo $dir|wc -l) -gt 1 ] ; then 
      echo "more than one directory found... \n$dir"
    elif [ "${dir}" == "" ]; then 
      echo "can't find that directory..."
    else
      cd $dir
    fi
  fi


}

function gpc() {
    #if osx, then pbcoby
    #else use xclip
    os=$(uname -s)
        branch=""
    if [[ -n "$2" ]]; then
      branch=$2
    else
      branch=$(git symbolic-ref --short HEAD)
    fi

    link=$(git push $1 $branch 2>&1|tee ~/tmp/gp.output|grep -oe "https://[a-z/0-9_\.-]\+")
    if [[ $os =~ "Darwin" ]]; then
        echo $link|pbcopy
    else
        echo $link|xclip -sel clip

   fi

    cat ~/tmp/gp.output
}
#function k9s() {
#  if [ -z $KUBECONTEXT ]; then 
#    k9s
#  else
#    k9s --context=$KUBECONTEXT 
#  fi 

#}

function kc () {
  if [ -z $KUBECONTEXT ]; then 
    kubectl "${@}"
  else
    #kubectl --context=$KUBECONTEXT "${@}"
    kubectl "${@}" --context=$KUBECONTEXT 
  fi 
}
function kc-update() {
    environ=$1

    if [[ $environ == "mohnz" ]]; then 
      kubectl config use-context "biahealthnz-prd"
      kubectl config set-context --current --namespace=dbt-cloud-biahealthnz-prd
      export KUBECONTEXT="biahealthnz-prd"
    else 
      if [[ $environ == 'prod' ]]; then 
        environ='dbt-cloud-prod'
      elif [[ $environ == 'au' ]]; then 
        environ='dbt-cloud-prod-au' 
      fi
      exact_context=$(kubectl config get-contexts -o name|grep "^${environ}$"|grep -v "teleport")
      context=$(kubectl config get-contexts -o name|grep $environ|grep -v teleport)

      if [ ! -z $exact_context ]; then 
        context=$exact_context
      elif [ $(echo $context |wc -l) -gt 1 ]; then 
        echo "More than one context found... "
        echo $context
        return 1;
      fi
      echo $context
      kubectl config use-context $context
      export KUBECONTEXT=$context
     
      # Because of weirdness setting AWS profile
      if  [[ $context =~ "dbt-cloud-" ]]; then # || [[ $context =~ "dbt-cloud-staging" ]]; then 
        if [[ $context == "dbt-cloud-prod-2" ]]; then 
            aws_profile="prod-admin"
        else
          aws_profile="$(echo $context|sed 's/dbt-cloud-//')-admin"
        fi
      elif  [[ $context =~ "dbt-labs-dev" ]]; then # || [[ $context =~ "dbt-cloud-staging" ]]; then 
        aws_profile="dev-admin"
      elif [[ $context =~ "aks" ]]; then
        aws_profile="infra-root-admin"
      else
        aws_profile="$(echo $context|sed -r 's/-.+//')-admin"
      fi
        export AWS_PROFILE=$aws_profile
    fi
}

function uk () {
  current=$(kc config current-context)
  kc-update $current
}
function kc-name() {
    kc config set-context --current --namespace=$1
}

function add-old-profiles() {
cat <<EOF >> ~/.aws/config
[profile infra-root]
sso_start_url = https://d-90677fe9e0.awsapps.com/start
sso_region = us-east-1
sso_account_id = 616349269060
sso_role_name = AdministratorAccess

[profile staging-single-tenant]
sso_start_url = https://d-90677fe9e0.awsapps.com/start
sso_region = us-east-1
sso_account_id = 719410363772
sso_role_name = AdministratorAccess

[profile dbt-cloud-prod-single-tenant]
sso_start_url = https://d-90677fe9e0.awsapps.com/start
sso_region = us-east-1
sso_account_id = 952445382732
sso_role_name = AdministratorAccess

[profile jump]
sso_start_url = https://d-90677fe9e0.awsapps.com/start
sso_region = us-east-1
sso_account_id = 703242591455
sso_role_name = AdministratorAccess

[profile vpn-jump]
sso_start_url = https://d-90677fe9e0.awsapps.com/start
sso_region = us-east-1
sso_account_id = 703242591455
sso_role_name = AdministratorAccess
EOF
}

function kc-config-all() {
  script_path=~/Repositories/dev-tools/scripts/config_update 
  git --work-tree=$script_path pull origin
  # ${script_path}/venv/bin/python3 ${script_path}/main.py -rd
  ${script_path}/venv/bin/python3 ${script_path}/main.py -r
  #add-old-profiles
}

function kc-config() {
#   SCRIPT_PATH="$HOME/Repositories/dev-tools/scripts/config_update"
#   PYTHON_PATH="${SCRIPT_PATH}/venv/bin/"
#   if [ -z "$1" ]; then 
#     echo "need to input client..."
#   else 
#     ${PYTHON_PATH}/python ${SCRIPT_PATH}/main.py --client $1
#   fi
  client=$1 
  env=$2 
  region="${3:-us-east-1}"
  
  aws --no-cli-pager --profile "${client}-dbt-cloud-single-tenant" sts get-caller-identity > /dev/null 2>&1 
  if [ $? -ne 0  ]; then 
    profile="dbt-cloud-prod-single-tenant"
  else
    profile="${client}-dbt-cloud-single-tenant"
  fi
  account=$(aws --profile "${profile}" sts get-caller-identity|jq -r .Account)
  aws eks update-kubeconfig --profile "$profile" --name "${client}-${env}" --role-arn "arn:aws:iam::${account}:role/TFCreationRole" --region=$region --alias ${client}-${env} && kc-name "dbt-cloud-${client}-${env}"
  aws eks update-kubeconfig --profile "$profile" --name "${client}-${env}"  --region=$region --alias ${client}-${env} && kc-name "dbt-cloud-${client}-${env}"
   
}

function kc-aconfig() {
    client=$1
    env=$2

    if [[ $client == "singletenantazure" ]]; then 
        az-update sandbox > /dev/null
    else
        az-update $client  > /dev/null
    fi
    az aks get-credentials --name "aks-${client}-${env}" --resource-group "${client}-${env}"  --overwrite-existing
    kc-name "dbt-cloud-${client}-${env}"
}

function az-update(){
  subscription=$1
  subscription_id=$(az account list |jq -r ".[]|select(.name|test(\"${subscription}\"))|.id")
  az account set --subscription=$subscription_id
  az account show

}
kots-admin() {
    ns=$(kc get ns -o name|grep dbt-cloud |sed 's/namespace\///')
    kc kots admin-console -n $ns
}

kots-upgrade() {
    ns=$(kc get ns -o name|grep dbt-cloud |sed 's/namespace\///')
    kc kots admin-console upgrade -n $ns
}
kots-download() {
  ns=$(kc get ns -o name|grep dbt-cloud |sed 's/namespace\///')
  dir=$(echo $ns |sed 's/dbt-cloud-//' )
  kc kots download dbt-cloud-v1 --decrypt-password-values -n $ns  --dest $dir --overwrite
}
function dingding() { 

    if [ $? -eq 0 ]; then 
      output_text="${1:-Job Done}"
    else 
      output_text="Job FAILED!"
    fi 

    # tput bel && sleep .3s &&  tput bel
    # sleep 2s
    curl -X POST --data-urlencode "payload={\"username\": \"webhookbot\", \"icon_emoji\": \":megusta:\",\"text\": \"${output_text}\"}" $SLACK_WEBHOOK_URL > /dev/null 2>&1
}

function bump-all-versions() {
    version=$1
    find . -name main.tf |grep -v "bootstrapping" |grep -v ".terraform"|xargs sed -i '' -E "s/ref=v.+/ref=${version}\"/"
}
function secret() {
   if [ -z $1 ]; then 
      echo "need name of secret to copy to clipboard..."
      return 1; 
   elif [[ $1 =~ 'adm' ]]; then 
      secret_key="admin_console_password"
   elif [[ $1 =~ 'super' ]]; then 
      secret_key="superuser_password"
   elif [[ $1 =~ 'arg' ]]; then 
      secret_key="argocd_password"
   else
      secret_key="${1}_password"
   fi

   # context=$(kubectl config current-context)
   context=$KUBECONTEXT
   parsed_context=$(echo $context|sed 's/aks-//'|sed 's/-/\//')
   secrets_json=$(aws --profile=infra-root-admin secretsmanager get-secret-value --secret-id "${parsed_context}/terraform")
   password=$(echo $secrets_json |sed -z 's/\\n//g' |jq -r '.SecretString| fromjson.'${secret_key})

   if [[ $2 == 'debug' ]]; then 
    echo $secrets_json
   fi 

   if [[ $password == "null" ]]; then 
    echo "${secret_key} does not exist..."
    return 1
   else 
     echo $password|pbcopy
     echo "${secret_key} for ${context} copied to clipboard..."
   fi
}

function curl_loop() {
  url=$1
  wait=${2:-10} 

  if [ -z "$url" ]; then 
    echo "need an url..."
    return 1
  fi

  while true; do
    curl --connect-timeout 3 -s https://sandbox.singletenantazure.getdbt.com > /dev/null
    if [ $? -ne 0 ]; then
    echo "Curl errored"
    else
    echo "..."
    fi
    sleep "${wait}s" 
  done
}

function ipamf () {
  ipam --full -s ${@} 
}
function ipams () {
  ipam -s ${@}
}
function ipam () {
  script_path=~/Repositories/dev-tools/scripts/deployment
  ${script_path}/venv/bin/python3 ${script_path}/ipam.py ${@}
}


#eval "$(direnv hook zsh)"

if [ $(ps -ef|grep ssh-agent|wc -l) -ge 2 ]; then
    export SSH_AUTH_SOCK=$(cat ~/tmp/.ssh-sock)
else
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa
    # ssh-add ~/.ssh/aws_infra
    # ssh-add ~/.ssh/integration-buildkite
    ls ~/.ssh/|grep pem |xargs -I{} ssh-add ~/.ssh/{}
    echo $SSH_AUTH_SOCK > ~/tmp/.ssh-sock
fi

if [ -z "$SSH_CONNECTION" ]; then
  if [ $(tmux ls|grep -v "(attached)"|wc -l) -gt 0 ]; then
    tmux at
  else
    tmux
   fi
fi

export ASDF_DIR=/usr/local/Cellar/asdf/0.10.2/libexec
. /usr/local/opt/asdf/asdf.sh

source ~/Repositories/forge/forge_completion.zsh

alias fgw="forge get-workspaces"
alias fgc="forge get-commands"
function f() {
    action=$1
    workspace=$2
    command="${@:3}"

    found_workspace=$(fgw|sed 's/\ /\n/g'|grep $workspace)
    exact_workspace=$(echo $found_workspace|egrep -e "^${workspace}$")
    # workspaces=$(echo $found_workspaces|grep $workspace)
   
    if [ -z "${found_workspace}" ] && [ -z "${exact_workspace}" ]; then 
        >&2 echo "couldn't find a workspace, exiting..."
        return 1
    elif [ ! -z "${exact_workspace}" ]; then 
      forge $action $exact_workspace $command
    else 
      if [ $(echo $found_workspace|wc -l) -gt 1 ]; then 
         >&2 echo "found more than one workspace, exiting..."
         >&2 echo $found_workspace
         return 1
      else 
         forge $action $found_workspace $command
      fi
    fi
}
function fr () {
  f run $1 "terraform ${@:2}"
}

function fri () { 
  fr $1 "init"
}
function frp () {
  fr $1 plan ${@:2}
}

function frip () {
  fr $1 "init --upgrade=true && terraform plan ${@:2}"
}

function fra () {
  fr $1 apply ${@:2}
}

function fria () {
  forge run $1 "terraform init && terraform apply ${@:2}"
}

function frsl() {
  fr $1 "state list" 
}

function frss() {
  fr $1 "state show ${@:2}"
}
# function fu () {

# }

set -o vi

#Beacuse AWS_PROFILE won't be set when you create a new session
uk
