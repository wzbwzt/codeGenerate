<template>
    <div>
        <div class="contentHeader">
      <span class="pageName">
        <h3>{{$route.name}}</h3>
      </span>
            <span class="actions"></span>
        </div>
        <div class="queryBody">
            <div class="hat-row">
                {{range .ColList }}{{if eq .Base false}}<span class="title">{{.ColComment}}:</span>
                <span>
                  <a-input style="width:178px" v-model="{{.LittleHumpColName}}"/>
                </span>{{end}}
                {{ end }}
            </div>
            <div class="hat-row">
          <span class="goRight">
          <a-button type="primary" @click="showModal('新增')">新增</a-button>
          <a-button type="primary" @click="handleSearch(1)">查询</a-button>
          <a-button :style="{ marginLeft: '8px' }" @click="handleReset">重置</a-button>
        </span>
            </div>
            <div class="total">
                <span>总条数：{{data.total}}</span>
            </div>
            <a-table
                    :columns="columns"
                    :loading="loading"
                    :dataSource="data.list"
                    :pagination="false"
                    size="middle"
                    @change="handleTableChange"
                    bordered
            >
                <template slot="operation" slot-scope="text, record">
                    <a
                            href="javascript:"
                            class="primary"
                            @click="showModal('修改', record)"
                    >修改</a>
                    <a-divider type="vertical" />
                    <a-popconfirm
                            v-if="data.list.length"
                            title="确定删除?"
                            @confirm="() => onDelete(record)"
                    >
                        <a href="javascript:" class="danger">删除</a>
                    </a-popconfirm>
                </template>
            </a-table>>
            <div class="hat-row">
        <span class="goRight">
          <a-pagination
                  v-model="current"
                  :total="data.total"
                  showSizeChanger
                  :pageSize.sync="params.pagination.pageSize"
                  @change="handleSearch"
          />
        </span>
            </div>
        </div>
        <a-modal
                :title="callDevice.id>0?'修改':'新增'"
                :visible="visible"
                @ok="handleOk"
                :okText="callDevice.id>0?'修改':'新增'"
                :confirmLoading="confirmLoading"
                @cancel="handleCancel"
                :width="700"
        >
            <a-form :form="form">
                <a-form-item
                        type="required"
                        label="设备编号"
                        :label-col="{ span: 6 }"
                        :wrapper-col="{ span: 14 }"
                >
                    <a-input
                            v-model="callDevice.deviceId"
                            placeholder="请输入设备编号"
                            :disabled="callDevice.id>0"
                    />
                </a-form-item>
                <a-form-item
                        type="required"
                        label="关联道闸"
                        :label-col="{ span: 6 }"
                        :wrapper-col="{ span: 14 }"
                >
                    <a-select
                            showSearch
                            :filter-option="filterOption"
                            placeholder="关联道闸"
                            v-model="callDevice.laneId"
                            @change="selectedLane"
                    >
                        <a-select-option
                                v-for="item in laneList"
                                :key="item.id"
                                :value="item.id"
                        >
                            {{ item.name }}
                        </a-select-option>
                    </a-select>
                </a-form-item>
                <a-form-item
                        type="required"
                        label="设备名称"
                        :label-col="{ span: 6 }"
                        :wrapper-col="{ span: 14 }"
                >
                    <a-input
                            v-model="callDevice.deviceName"
                            placeholder="请输入设备名称"
                    />
                </a-form-item>
                <a-form-item
                        label="关联萤石云"
                        :label-col="{ span: 6 }"
                        :wrapper-col="{ span: 14 }"
                >
                    <a-input
                            v-model="callDevice.ysCloud"
                            placeholder="请输入萤石云信息"
                    />
                </a-form-item>
                <a-form-item
                        label="萤石云通道号"
                        :label-col="{ span: 6 }"
                        :wrapper-col="{ span: 14 }"
                >
                    <a-input
                            v-model="callDevice.ysChannel"
                            placeholder="请输入萤石云通道号"
                    />
                </a-form-item>
                <a-form-item
                        type="required"
                        label="出入方向"
                        :label-col="{ span: 6 }"
                        :wrapper-col="{ span: 14 }"
                >
                    <a-radio-group buttonStyle="solid" v-model="callDevice.deviceDirection">
                        <a-radio-button :value="0">入口</a-radio-button>
                        <a-radio-button :value="1">出口</a-radio-button>
                    </a-radio-group>
                </a-form-item>
                <a-form-item :wrapper-col="{ span: 12, offset: 5 }"></a-form-item>
            </a-form>
        </a-modal>
    </div>
</template>
<script>
    export default {
        data() {
            return {
                loading: false,
                confirmLoading: false,
                visible: false,
                spinning: false,
                data: {total: 0, list: []},
                params: {},
                current: 1,
                columns: [
                    {
                        title: "设备编号",
                        dataIndex: "code",
                        sorter: true
                    },
                    {{range .ColList }}{{if eq .Base false}}{
                        title: "{{.ColComment}}",
                        dataIndex: "{{.LittleHumpColName}}",
                        sorter: true
                    },{{end}}
                {{ end }}
                ],
                {{.LittleHumpTableName }}: {
                    id: 0,
                    {{range .ColList }}{{if eq .Base false}}{{.LittleHumpColName}}:null,{{end}}
                    {{ end }}
                },

            };
        },
        watch: {
            params: {
                handler(newVal, oldVal) {
                    this.handleSearch(1);
                },
                deep: true
            }
        },
        created() {
            this.initParams();
        },
        methods: {
            initParams() {
                this.params = {
                    projId: parseInt(this.$route.params.projId),
                    {{range .ColList }}{{if eq .Base false}}{{.LittleHumpColName}}:null,{{end}}
                    {{ end }}
                    pagination: {pageSize: 10,},
                    sorter: {field: "id", order: 0}
                };

                this.current = 1;
            },
            handleTableChange(pagination, filters, sorter) {
                if (sorter.order) {
                    this.params.sorter.field = sorter.field;
                    if (sorter.order === "descend") {
                        this.params.sorter.order = 0;
                    } else if (sorter.order === "ascend") {
                        this.params.sorter.order = 1;
                    }
                } else {
                    this.params.sorter.order = 1;
                    this.params.sorter.field = "netState";
                }
            },
            handleSearch(page) {
                this.params.pagination.current = page;
                this.current = page;

                this.loading = true;
                this.$hat.convertEmptyToNull(this.params);
                this.$api.{{.LittleHumpTableName }}List(this.params).then(data => {
                    this.data = data.data;
                    //当total>0,却list=[]，翻到第一页
                    if (this.data.total > 0 && !this.data.list) {
                        this.params.pagination.current = 1;
                    }
                    this.loading = false;
                });
            },
            handleReset() {
                this.initParams();
            },
            onDelete(record) {
                this.loading = true;
                this.$api.{{.LittleHumpTableName}}Del({id: record.id,}).then((res) => {
                    this.loading = false;
                    if (res.code === 10000) {
                        this.$message.success("删除{{.TableComment}}成功");
                        this.handleReset();
                    } else {
                        this.$message.error(res.msg);
                    }
                });
            },
            showModal(text, record) {
                this.spinning = true;
                if (record) {
                    this.$api.{{.LittleHumpTableName}}Info({ id: record.id }).then((res) => {
                        this.spinning = false;
                        if (res.code === 10000) {
                            this.{{.LittleHumpTableName }}: {
                                id: res.data.id,
                                {{range .ColList }}{{if eq .Base false}}{{.LittleHumpColName}}:res.data.{{.LittleHumpColName}},{{end}}
                                {{ end }}
                            }
                        } else {
                            this.$message.error(res.msg);
                        }
                    });
                } else {
                    this.spinning = false;
                    this.{{.LittleHumpTableName }}: {
                        id: 0,
                            {{range .ColList }}{{if eq .Base false}}{{.LittleHumpColName}}:null,{{end}}
                        {{ end }}
                    }
                }
            },
            handleOk(e) {
                e.preventDefault();
                this.{{.LittleHumpTableName }}Form.validateFields((err, values) => {
                    console.log(values);
                    values.id = this.dict.id;

                    this.confirmLoading = true;
                    if (!this.{{.LittleHumpTableName }}.id || this.{{.LittleHumpTableName }}.id === 0) {
                        let projId = parseInt(this.$route.params.projId);
                        this.$api.{{.LittleHumpTableName }}Add(values).then(data => {
                            if (data && data.code === 10000) {
                                this.visible = false;
                                this.handleSearch(1);
                                this.$message.success("新增{{.TableComment}}成功");
                            }
                            this.confirmLoading = false;
                        });
                    } else {
                        this.$api.{{.LittleHumpTableName }}Update(values).then(data => {
                            if (data && data.code === 10000) {
                                this.visible = false;
                                this.handleSearch(1);
                                this.$message.success("修改{{.TableComment}}成功");
                            }
                            this.confirmLoading = false;
                        });
                    }
                });
            },
            handleCancel(e) {
                this.visible = false;
            }
        }
    };
</script>
<style>
</style>