<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%@ include file="/WEB-INF/views/include/taglib.jsp"%>
<jsp:include page="/WEB-INF/views/include/base-include.jsp">
	<jsp:param name="include" value="base,layer,jqgrid,select2,app" />
</jsp:include>

<title>操作日志管理</title>
</head>
<script type="text/javascript">
	var module = "sysOperateLog";
	var tableObj = null;
	$(document).ready(function() {
		tableObj = $("#dataTable").jqGrid({
			caption : "操作日志列表",
			url : _ctxRoot + "/sysOperateLog/sysOperateLogList",
			sortname : "OPERATE_TIME",
			sortorder :"DESC",
			multiselect : false,
			colModel : [ 
				{label : "id", name : "logId", hidden : true, key : true}, 
				{label : "操作人", name : "operateUserName", index : "OPERATE_USER_NAME", align : 'center'}, 
				{label : "操作时间", name : "operateTime", index : "OPERATE_TIME", align : 'center', formatter: "date", formatter: timeFormatter}, 
				{label : "操作日志名称", name : "operateName", index : "OPERATE_NAME", align : 'center'}, 
				{label : "操作路径", name : "requestUrl", index : "REQUEST_URL", align : 'center'},
				{label : "操作表", name : "tableName", index : "TABLE_NAME", align : 'center'},
				{label : "操作类型", name : "operateType", index : "OPERATE_TYPE", align : 'center', formatter: operateTypeFormatter},
				{label : "updateParams", name : "updateParams", hidden : true}, 
				{label : "操作", name : "operator", align : 'center', sortable : false, formatter: operatorFormatter}
			],
			postData : getParams()
		});
		//初始化加载调整宽度和注册宽度时间
		resizeWindow();

		// 搜索
		$("#searchForm").submit(function(e){
			e.preventDefault();
			tableObj.setGridParam({postData:getParams(),page:1});
			tableObj.trigger("reloadGrid");
		});
	});

	function getParams() {
		var param = {
				operateName : $("#operateName").val(),
				operateType : $("#operateType").val()
		};
		return {'param':JSON.stringify(param)};
	}
	
	/*
	 * 重新调整jqgrid高度与宽度
	 */
	function resizeWindow() {
		var height = $(document).height() - $("#searchForm").height() - 126;
		tableObj.setGridHeight(height);
		$(window).on("resize", resizeWindow);
	}

	/*********************************formatter start**********************************/
	function operatorFormatter(cellValue, options, rowObject){
		var operateType = rowObject.operateType;
		if (operateType == "-1" || operateType == "0" || operateType == "1" || operateType == "6") {
			return "";
		}
		var id = rowObject.logId;
		var lookBtn = "<button class='btn btn-success btn-xs' title='查看详情' onclick=\"openCurForm('"+id+"')\"><i class='fa fa-eye'></i>&nbsp;查看详情</button>";
		return lookBtn;
	}
	
	function timeFormatter(cellValue, options, rowObject){
		return new Date(cellValue).Format("yyyy-MM-dd hh:mm:ss");
	}

	function operateTypeFormatter(cellValue, options, rowObject){
		var operateType = "";
		switch (cellValue) {
		case "-1":
			operateType = "退出系统";
			break;
		case "0":
			operateType = "进入系统";
			break;
		case "1":
			operateType = "查询";
			break;
		case "2":
			operateType = "新增";
			break;
		case "3":
			operateType = "更新";
			break;
		case "4":
			operateType = "删除";
			break;
		case "5":
			operateType = "保存（新增或更新）";
			break;
		case "6":
			operateType = "导入";
			break;
		}
		return operateType;
	}
	/*********************************formatter end**********************************/
	function openCurForm(logId){
		var rowObject = tableObj.getRowData(logId);
		var updateParams = JSON.parse(rowObject.updateParams);
		var content = "<p style='color:red'>操作名称："+rowObject.operateName+"</p>";
		if (updateParams instanceof Array) {
			for ( var i in updateParams) {
				var item = updateParams[i];
				content += "<table class='table'>";
				content += "<caption>序号："+(parseInt(i)+1)+"</caption>";
				content += "<tr><th>属性名</th><th>属性值</th></tr>";
				for ( var key in item) {
					var temp = item[key];
					content += "<tr><td>"+key+"</td><td>"+temp+"</td></tr>";
				}
				content += "</table>";
			}
		} else {
			content += "<table class='table'>";
			content += "<caption>序号：1</caption>";
			content += "<tr><th>属性名</th><th>属性值</th></tr>";
			for ( var key in updateParams) {
				var temp = updateParams[key];
				content += "<tr><td>"+key+"</td><td>"+temp+"</td></tr>";
			}
			content += "</table>";
		}
		layer.alert(content,{
			title : "操作详情",
			area : ["40%","80%"]
		});
	}
</script>
<body>
	<div>
		<form action="javascript:void(0);" class="form form-inline" id="searchForm">
			<div class="form-group">
				<label class="control-label">操作日志名称：</label> 
				<input class="form-control" name="operateName" id="operateName"> 
				<label class="control-label">操作类型：</label> 
				<select class="form-control" name="operateType" id="operateType">
					<option value="">全部</option>
					<option value="-1">退出系统</option>
					<option value="0">进入系统</option>
					<option value="1">查询</option>
					<option value="2">新增</option>
					<option value="3">更新</option>
					<option value="4">删除</option>
					<option value="5">保存（新增或更新）</option>
					<option value="6">导入</option>
				</select>
			</div>

			<button id="search" type="submit" class="btn btn-info">
				<span class="glyphicon glyphicon-search"></span>&nbsp;搜索
			</button>
		</form>
		<div class="col-xs-12">
			<div>
				<table id="dataTable"></table>
				<div id="pager"></div>
			</div>
		</div>
	</div>
</body>
</html>