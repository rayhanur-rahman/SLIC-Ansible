#
# Cookbook Name:: my_cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

file "/tmp/local_mode.txt" do
	content "create by chef client local mode"
	end
