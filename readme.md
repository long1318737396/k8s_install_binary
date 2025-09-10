# k8s_install_binary

Kubernetes二进制安装脚本集合，用于快速部署Kubernetes集群环境。

## 项目介绍

本项目提供了一套完整的Kubernetes集群二进制安装脚本，帮助用户快速搭建生产级别的Kubernetes环境。通过自动化脚本减少手动配置的复杂性和出错概率。

## 目录结构


## 功能特性

- 支持多种Linux发行版（CentOS/RHEL/Ubuntu）
- 自动化证书生成和分发
- 集成etcd集群部署
- 支持高可用Master配置
- 自动配置网络插件（Calico/Flannel）
- 一键部署和清理功能

## 环境要求

- 操作系统：CentOS 7.x / Ubuntu 18.04+
- 内存：至少4GB（Master节点建议8GB以上）
- 硬盘：至少50GB可用空间
- 网络：各节点间网络互通

## 使用方法

### 1. 克隆项目

```bash
git clone https://github.com/long1318737396/k8s_install_binary.git
cd k8s_install_binary